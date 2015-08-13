class WordsController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper

  def index
    if params[:language]
      lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
      @language_name = lang.name
      @words = Word.paginate(:page => params[:page], :per_page => 250).where 'user_id = ? and rating < 6 and language_id = ?', current_user.id, lang.id
    end
  end

  def show
    lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
    @word = Word.find_by value: utf8downcase(params[:id]), language_id: lang.id, user_id: current_user.id
    if @word
      output = {
        value: @word.value,
        note: @word.note.strip,
        language: @word.language.name,
        rating: @word.rating
      }
    else
      if selected_language
        output = {
          value: utf8downcase(params[:id]),
          note: "",
          language: selected_language.name,
          rating: 0
        }
      else
        output = params
      end
    end
    render json: output
  end

  def update
    lang = Language.where("lower(name) = ?", params[:word][:language].downcase)[0]
    @word = Word.find_by value: utf8downcase(params[:id]), language_id: lang.id, user_id: current_user.id

    if not @word
      @word = Word.new value: utf8downcase(params[:id]), language_id: lang.id, user_id: current_user.id
      @word.save
    end

    params[:word][:language] = lang
    params[:word][:note] = params[:word][:note].strip

    if @word.update(word_params)
      render plain: "ok"
    else
      render plain: "failure"
    end

    @word.delete if @word.note == '' and @word.rating == 0
  end

  private
    def word_params
      params.require(:word).permit(:language, :note, :rating)
    end
end
