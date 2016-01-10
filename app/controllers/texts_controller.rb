class TextsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper
  include WordsHelper

  def autocomplete_text_category
    term = params[:term]
    lang = Language.where("lower(name) = ?", params[:lang].downcase)[0]
    texts = Text.where('lower(category) like ? and user_id = ? and language_id = ?', "%#{utf8downcase term}%", current_user.id, lang.id).group('category').select('category').order('category asc')
    cats = texts.map { |t| t.category }
    render :text => cats.to_json
  end

  def vocabulary
    @text = Text.find params[:id]
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path, alert: 'You are not allowed to do that.'
    else
      if current_user.native_language_id != @text.language_id
        uniq_words = (@text.raw_words + @text.raw_words_title + @text.raw_words_category).sort.uniq
        @words = Note.find_create_bulk @text.language, uniq_words, current_user
        @words = @words.sort
        @words.map { |k, w|
          w.word.value.gsub! '..', ' ... '
          w.word.value.gsub! '...', ' ... '
          w.word.value.gsub! '_', ' '
        }
      end
    end
  end

  def copy
    @text = Text.find_by id: params[:id]
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path, alert: 'You are not allowed to do that.'
    else
      @new_text = @text.dup
      @new_text.user_id = current_user.id
      @new_text.public = false
      @new_text.hidden = false
      @new_text.save
      redirect_to text_path(@new_text), notice: 'Text has been successfully copied into your library.'
    end
  end

  def create
    @text = Text.new(text_params)
    @text.user_id = current_user.id
    @text.public = false unless current_user.admin?

    if @text.save
      @text.save
      redirect_to @text, notice: 'New text has been successfully added.'
    else
      if @text.language
        params[:language] = @text.language.name
      end
      render 'new'
    end
  end

  def edit
    @text = Text.find params[:id]
    if not @text.is_allowed_to_update current_user
      @text = nil
    end
  end

  def destroy
    @text = Text.find params[:id]
    
    if @text.is_allowed_to_update current_user
      @text.destroy
    end

    url = '/texts/' + @text.language.name.downcase
    if @text.public
      url += '/public'
    elsif @text.hidden
      url += '/archive'
    end
    url += '#' + @text.category

    redirect_to url, notice: 'Text has been successfully deleted.'
  end

  def index_language
    @languages = Language.order(:name).all
  end

  def index hidden = false, public = false
    selected_category = params[:c]

    if current_language == nil
      my_texts = []
    else
      if public
        my_texts = Text.where(language: current_language, public: true, category: selected_category).order('category asc, title asc')
      else
        my_texts = Text.where(language: current_language, hidden: hidden, user: current_user, public: false, category: selected_category).order('category asc, title asc')
      end
    end
    @hidden = hidden
    @public = public

    if my_texts.any?
      @texts = {}
      my_texts.each do |t|
        @texts[t.category] = [] if not @texts.has_key? t.category
        @texts[t.category] += [t]
      end

      @texts.each { |category, texts|
        texts.sort! do |a, b|
          if a.title == b.title
            0
          elsif [a.title, b.title].natural_sort[0] == a.title
            -1
          else
            1
          end
        end
        @texts[category] = texts
      }
      @texts = @texts.sort.to_h
    else
      @texts = {}
    end

    if public
      @categories = Text.where(public: true, language: current_language).select('category, count(texts.id) as count').group(:category).map { |t| [t.category, t.count] }.sort.to_h
    else
      @categories = Text.where(user: current_user, hidden: hidden, public: false, language: current_language).select('category, count(texts.id) as count').group(:category).map { |t| [t.category, t.count] }.sort.to_h
    end

    if selected_category
      render 'index_texts'
    else
      render 'index'
    end
  end

  def index_hidden
    index true
  end

  def index_public
    index false, true
  end

  def new
    @text = Text.new
  end

  def show
    @text = Text.find params[:id]

    disabled_words = true if not current_user.real?
    disabled_words = true if current_user.native_language_id == current_language.id
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path, alert: 'You are not allowed to do that.'
    else
      if current_user.native_language_id != current_language.id
        uniq_words = (@text.raw_words + @text.raw_words_title + @text.raw_words_category).sort.uniq
        notes = Note.find_create_bulk @text.language, uniq_words, current_user
      else
        notes = {}
      end
      @processed_text = process_text @text.content, notes, @text.language, disabled_words
      @processed_title = process_text @text.title, notes, @text.language, disabled_words
      @processed_category = process_text @text.category, notes, @text.language, disabled_words

      @services = Service.where('(language_id=? or language_id=0) and user_id = ? and enabled = true', @text.language_id, current_user.id)
      @services = [] if @services == nil
    end
  end

  def update
    @text = Text.find params[:id]

    if params[:completed] and ((current_user.id != @text.id) or @text.public)
      render plain: "not allowed"
    elsif not @text.public or current_user.admin?
      if text_params[:public] and not current_user.admin?
        text_params[:public] = false
      end

      if text_params[:bulk_update]
        Text.where(category: @text.category, language_id: @text.language_id, public: @text.public, hidden: @text.hidden).update_all(category: text_params['category'], public: text_params['public'], hidden: text_params['hidden'])
        return redirect_to texts_path(current_language), notice: 'Category has been successfully updated.'
      end
      
      if @text.update(text_params)
        @text.save
        if text_params[:completed]
          render plain: "ok"
        else
          redirect_to @text, notice: 'Text has been successfully updated'
        end
      else
        render 'edit'
      end
    else
      redirect_to @text, alert: 'Text could not be updated!'
    end
  end

  private
    def text_params
      params.require(:text).permit(:category, :title, :content, :language_id, :completed, :hidden, :public, :audio_url, :bulk_update)
    end
end
