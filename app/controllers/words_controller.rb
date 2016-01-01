class WordsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @languages = Language.order(:name).all
    
    if params[:language]
      @search_term = params['q']
      @search_term = '' if not @search_term
      lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
      @language_name = lang.name

      if @search_term == nil || @search_term.split == ''
        @notes = Note.includes(:word).joins(:word).order('notes.created_at DESC').paginate(page: params[:page], per_page: 250).where 'user_id = ? and rating < 6 and language_id = ?', current_user.id, lang.id
      else
        @notes = Note.includes(:word).joins(:word).order('notes.created_at DESC').paginate(page: params[:page], per_page: 250).where('user_id = ? and rating < 6 and language_id = ? and (words.value ilike ? or notes.value ilike ?)', current_user.id, lang.id, "%#{@search_term}%", "%#{@search_term}%")
      end
    end
  end

  def show
    lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
    @word = Note.find_create lang, utf8downcase(params[:id]), current_user
    render json: {
      value: @word.word.value,
      note: @word.value.strip,
      language: @word.word.language.name,
      rating: @word.rating
    }
  end

  def edit
    @word = Word.find_by value: params[:id], language: current_language
    @note = Note.find_by word: @word, user: current_user
    @occurrences = Occurrence.includes(:text).joins(:text).where('word_id = ? AND texts.user_id = ? AND texts.public = FALSE', @word.id, current_user.id).paginate(page: params[:page], per_page: 20)
  end

  def vocab_set
    @word = Word.find_by value: params[:id], language: current_language
    @note = Note.find_by word: @word, user: current_user
    if @note.update_column('vocabulary', true)
      render plain: "ok"
    else
      render plain: "failure"
    end
  end

  def vocab_unset
    @word = Word.find_by value: params[:id], language: current_language
    @note = Note.find_by word: @word, user: current_user
    if @note.update_column('vocabulary', false)
      render plain: "ok"
    else
      render plain: "failure"
    end
  end

  def update
    lang = Language.where("lower(name) = ?", params[:word][:language].downcase)[0]
    @note = Note.find_create lang, utf8downcase(params[:id]), current_user
    @note.value = params[:word][:note].strip if params[:word][:note]
    @note.rating = params[:word][:rating] if params[:word][:rating]
    @note.updated_at = DateTime.now
    
    if @note.word.save and @note.save
      render plain: "ok"
    else
      render plain: "failure"
    end

    if @note.value == '' and @note.rating == 0
      nodes = Note.where word: @note.word
      if nodes.length <= 1
        @note.word.delete
      end
      Note.where(word: @note.word, user: current_user).delete_all
    end
  end

  private
    def word_params
      params.require(:word).permit(:language, :note, :rating)
    end
end
