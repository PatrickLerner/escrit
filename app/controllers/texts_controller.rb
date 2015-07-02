class TextsController < ApplicationController
  include TextsHelper

  def create
    @text = Text.new(text_params)

    if @text.save
      @text.hidden = false
      @text.update_word_count
      @text.save
      redirect_to @text
    else
      params[:language] = @text.language.name
      render 'new'
    end
  end

  def edit
    @text = Text.find_by :id => params[:id]
  end

  def destroy
    @text = Text.find_by :id => params[:id]
    @text.destroy

    redirect_to '/texts/' + @text.language.name
  end

  def index hidden = false
    if selected_language == nil
      my_texts = []
    else
      my_texts = Text.where :language_id => selected_language.id, :hidden => hidden
    end
    my_texts = [] if my_texts == nil
    @hidden = hidden

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
  end

  def index_hidden
    index true
    render 'index'
  end

  def new
    @text = Text.new
  end

  def show
    @text = Text.find_by :id => params[:id]
    
    if @text == nil
      redirect_to texts_path
    else
      uniq_words = (@text.raw_words + @text.raw_words_title).sort.uniq
      words = Word.find_create_bulk @text.language_id, uniq_words

      @processed_text = process_text @text.split_words, words
      @processed_title = process_text @text.split_words_title, words

      @services = Service.where('language_id=? OR language_id=0', @text.language_id)
      @services = [] if @services == nil
    end
  end

  def update
    @text = Text.find_by :id => params[:id]

    if @text.update(text_params)
      @text.update_word_count
      @text.save
      redirect_to @text
    else
      render 'edit'
    end
  end

  private
    def text_params
      params.require(:text).permit(:category, :title, :content, :language_id, :completed, :hidden)
    end
end
