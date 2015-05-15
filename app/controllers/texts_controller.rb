class TextsController < ApplicationController
  def create
    @text = Text.new(text_params)
    @language_options = Language.all.map { |l| [l.name, l.id] }
    @language_options = [] if @language_options == nil

    if @text.save
      @text.update_word_count
      @text.save
      redirect_to @text
    else
      render 'new'
    end
  end

  def edit
    @text = Text.find_by :id => params[:id]
    @language_options = Language.all.map { |l| [l.name, l.id] }
    @language_options = [] if @language_options == nil
  end

  def destroy
    @text = Text.find_by :id => params[:id]
    @text.destroy

    redirect_to texts_path
  end

  def index
    @texts = Text.all
    @texts = [] if @texts == nil
  end

  def new
    @text = Text.new
    @language_options = Language.all.map { |l| [l.name, l.id] }
    @language_options = [] if @language_options == nil
  end

  def show
    @text = Text.find_by :id => params[:id]
    
    if @text == nil
      redirect_to texts_path
    else
      uniq_words = @text.raw_words.sort.uniq
      words = Word.find_create_bulk @text.language_id, uniq_words

      @processed = ''
      @text.split_words.each do |wstr|
        wstrlow = wstr.mb_chars.downcase.to_s
        if words.keys.include? wstrlow
          w = words[wstrlow]
          @processed += '<span class="word s' + w.rating.to_s + '">' + wstr + '</span>';
        else
          @processed += wstr
        end
      end
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
      params.require(:text).permit(:category, :title, :content, :language_id)
    end
end
