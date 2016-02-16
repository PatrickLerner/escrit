class WordsController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper
  include TextsHelper
  using StringRefinements

  before_action :authenticate_user!
  before_action :load_word, only: [:vocab_unset, :vocab_set, :edit, :show]

  def index
    @search_term = (params['q'] || '').strip

    @notes = Note.for(current_user, current_language)
                 .paginate(page: params[:page], per_page: 250)
    if @search_term != ''
      @notes = @notes.where('words.value ilike ? or notes.value ilike ?',
                            "%#{@search_term}%", "%#{@search_term}%")
    end
  end

  def sentence
    @word = Word.find_by value: params[:id], language: current_language
    occurrence = Occurrence.includes(:text).joins(:text)
      .where(
        'word_id = ? AND texts.user_id = ? AND texts.public = FALSE',
        @word.id,
        current_user.id
      ).sample

    if occurrence
      sample = occurrence.text.occurrences(@word.value).sample
      raw = ActionView::Base.full_sanitizer.sanitize(sample)
      sentence = "#{sample}<br><i>(#{occurrence.text.title} - " \
                 "#{occurrence.text.category})</i>"
    else
      sentence = 'Could not find any example sentence for this word ' \
                 'in your library.'
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
      vocabulary: @note.vocabulary?
    }
  end

  def edit
    @occurrences = Occurrence.includes(:text).joins(:text).where(
      'word_id = ? AND texts.user_id = ? AND texts.public = FALSE',
      @word.id,
      current_user.id
    ).paginate(page: params[:page], per_page: 20)
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
    @note = Note.find_create(
      lang,
      params[:id].utf8downcase,
      current_user
    )

    @note.value = params[:word][:note].strip if params[:word][:note]
    @note.rating = params[:word][:rating]    if params[:word][:rating]
    @note.update_review_at!                  if params[:word][:reviewed]

    if @note.word.save and @note.save
      render plain: "ok"
    else
      render plain: "failure"
    end

    if @note.value == '' and @note.rating == 0
      nodes = Note.where word: @note.word

      @note.word.delete if nodes.length <= 1

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
