class WordsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper

  before_filter :load_word, only: [ :vocab_unset, :vocab_set, :edit, :show ]

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    if params[:language]
      @search_term = params['q']
      @search_term = '' if not @search_term
      lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
      @language_name = lang.name

      if @search_term == nil || @search_term.strip == ''
        @notes = Note.includes(:word).joins(:word).order('notes.created_at DESC').paginate(page: params[:page], per_page: 250).where 'user_id = ? and rating < 6 and language_id = ?', current_user.id, lang.id
      else
        @notes = Note.includes(:word).joins(:word).order('notes.created_at DESC').paginate(page: params[:page], per_page: 250).where('user_id = ? and rating < 6 and language_id = ? and (words.value ilike ? or notes.value ilike ?)', current_user.id, lang.id, "%#{@search_term}%", "%#{@search_term}%")
      end
    end
  end

  def sentence
    @word = Word.find_by value: params[:id], language: current_language
    oc = Occurrence.includes(:text).joins(:text).where('word_id = ? AND texts.user_id = ? AND texts.public = FALSE', @word.id, current_user.id).sample
    if oc
      sample = oc.text.occurrences(@word.value).sample
      raw = ActionView::Base.full_sanitizer.sanitize(sample)
      sentence = "#{sample}<br><i>(#{oc.text.title} - #{oc.text.category})</i>"
    else
      sentence = 'Could not find any example sentence for this word in your library.'
      raw = ''
    end
    render json: {
      value: sentence,
      raw: raw
    }
  end

  def show
    render json: {
      value: @word.value,
      value_clean: @word.value_clean,
      note: @note.value,
      language: @word.language.name,
      rating: @note.rating,
      vocabulary: (@note.vocabulary == true)
    }
  end

  def edit
    @occurrences = Occurrence.includes(:text).joins(:text).where('word_id = ? AND texts.user_id = ? AND texts.public = FALSE', @word.id, current_user.id).paginate(page: params[:page], per_page: 20)
  end

  def vocab_set
    if @note.update_column('vocabulary', true)
      @note.update_review_at!
      render plain: "ok"
    else
      render plain: "failure"
    end
  end

  def vocab_unset
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
    @note.update_review_at! if params[:word][:reviewed]
    
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
    def load_word
      @note = Note.find_create current_language, params[:id].downcase, current_user
      @word = @note.word
    end

    def word_params
      params.require(:word).permit(:language, :note, :rating, :reviewed)
    end
end
