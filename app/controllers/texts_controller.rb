class TextsController < ApplicationController
  before_filter :authenticate_user!
  include TextsHelper

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

    if @text.save
      @text.hidden = false
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
      @total_text_count_public = 0
    else
      if public
        my_texts = Text.where language_id: selected_language.id, public: true
      else
        my_texts = Text.where language_id: selected_language.id, hidden: hidden, user_id: current_user.id, public: false
      end

      @total_text_count = Text.where(language_id: selected_language.id, user_id: current_user.id).count
      @total_text_count_public = Text.where(language_id: selected_language.id, user_id: current_user.id, public: true).count
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
    @text = Text.find_by id: params[:id]
    
    if @text == nil or (@text.user_id != current_user.id and not current_user.admin? and not @text.public)
      redirect_to texts_path
    else
      uniq_words = (@text.raw_words + @text.raw_words_title + @text.raw_words_category).sort.uniq
      words = Word.find_create_bulk @text.language_id, uniq_words, current_user.id

      @processed_text = process_text @text.split_words, words
      @processed_title = process_text @text.split_words_title, words
      @processed_category = process_text @text.split_words_category, words

      @services = Service.where('(language_id=? or language_id=0) and user_id = ?', @text.language_id, current_user.id)
      @services = [] if @services == nil
    end
  end

  def update
    @text = Text.find_by :id => params[:id]

    if not @text.public or current_user.admin?
      if params[:public] and not current_user.admin?
        params[:public] = false
      end
      
      if @text.update(text_params)
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
      params.require(:text).permit(:category, :title, :content, :language_id, :completed, :hidden, :public)
    end
end
