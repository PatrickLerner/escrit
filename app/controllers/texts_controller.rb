class TextsController < ApplicationController
  before_filter :authenticate_user!
  include TextsHelper

  #autocomplete :text, :category, :full => true

  def autocomplete_text_category
    term = params[:term]
    if (params[:lang])
      texts = Text.where('category like ? and user_id = ? and language_id = ?', "%#{term}%", current_user.id, params[:lang]).group('category').select('category').order('category asc')
    else
      texts = Text.where('category like ? and user_id = ?', "%#{term}%", current_user.id).group('category').select('category').order('category asc')
    end
    cats = texts.map { |t| t.category }
    render :text => cats.to_json
  end

  def copy
    @text = Text.find_by id: params[:id]
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path
    else
      @new_text = @text.dup
      @new_text.user_id = current_user.id
      @new_text.public = false
      @new_text.hidden = false
      @new_text.save
      redirect_to text_path(@new_text)
    end
  end

  def create
    @text = Text.new(text_params)
    @text.user_id = current_user.id
    @text.public = false unless current_user.admin?
    @text.category = @text.category.strip
    @text.content = @text.content.strip
    @text.title = @text.title.strip

    if @text.save
      @text.update_word_count
      @text.save
      redirect_to @text
    else
      if @text.language
        params[:language] = @text.language.name
      end
      render 'new'
    end
  end

  def edit
    @text = Text.find_by id: params[:id]
    if not @text.is_allowed_to_update current_user
      @text = nil
    end
  end

  def destroy
    @text = Text.find_by id: params[:id], user_id: current_user.id
    
    if not @text.public or current_user.admin?
      @text.destroy
    end

    redirect_to '/texts/' + @text.language.name
  end

  def index hidden = false, public = false
    @languages = Language.order(:name).all

    if selected_language == nil
      my_texts = []
      @total_text_count = 0
      @total_text_count_read = 0
      @total_text_count_public = 0
    else
      if public
        my_texts = Text.where(language_id: selected_language.id, public: true).order('category asc, title asc')
      else
        my_texts = Text.where(language_id: selected_language.id, hidden: hidden, user_id: current_user.id, public: false).order('category asc, title asc')
      end

      @total_text_count = Text.where(language_id: selected_language.id, user_id: current_user.id, public: false).count
      @total_text_count_read = Text.where(language_id: selected_language.id, user_id: current_user.id, completed: true, public: false).count
      @known_word_count = Word.where('rating >= 3 and rating < 6 and language_id = ? and user_id = ?', selected_language.id, current_user.id).count
      @word_count = Word.where('rating != 6 and language_id = ? and user_id = ?', selected_language.id, current_user.id).count
    end
    my_texts = [] if my_texts == nil
    @hidden = hidden
    @public = public

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
    @texts = @texts.sort

    @compliment = ""
    if selected_language != nil and @word_count > 0
      compliments = Compliment.where language_id: selected_language.id
      if compliments.count == 0
        compliments = Compliment.where language_id: 0
      end
      if compliments.count > 0
        @compliment = compliments.sample.value
      end
    end
  end

  def index_hidden
    index true
    render 'index'
  end

  def index_public
    index false, true
    render 'index'
  end

  def new
    @text = Text.new
  end

  def show
    if params[:user] and current_user.admin?
      user_id = params[:user]
    else
      user_id = current_user.id
    end
    @user = User.find_by id: user_id
    disabled_words = (user_id != current_user.id)

    @text = Text.find_by id: params[:id]
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path
    else
      if @user.native_language_id != @text.language_id
        uniq_words = (@text.raw_words + @text.raw_words_title + @text.raw_words_category).sort.uniq
        words = Word.find_create_bulk @text.language_id, uniq_words, @user.id
      else
        words = {}
      end
      @processed_text = process_text @text.split_words, words, @text.language_id, disabled_words
      @processed_title = process_text @text.split_words_title, words, @text.language_id, disabled_words
      @processed_category = process_text @text.split_words_category, words, @text.language_id, disabled_words

      @services = Service.where('(language_id=? or language_id=0) and user_id = ?', @text.language_id, current_user.id)
      @services = [] if @services == nil
    end
  end

  def update
    @text = Text.find_by :id => params[:id]

    if text_params[:completed] and not current_user.id == @text.id
      render plain: "not allowed"
    end

    if not @text.public or current_user.admin?
      if params[:public] and not current_user.admin?
        params[:public] = false
      end
      
      if @text.update(text_params)
        @text.category = @text.category.strip
        @text.content = @text.content.strip
        @text.title = @text.title.strip
        @text.update_word_count
        @text.save
        if text_params[:completed]
          render plain: "ok"
        else
          redirect_to @text
        end
      else
        render 'edit'
      end
    else
      redirect_to @text
    end
  end

  private
    def text_params
      params.require(:text).permit(:category, :title, :content, :language_id, :completed, :hidden, :public, :audio_url)
    end
end
