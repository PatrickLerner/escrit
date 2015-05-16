class WordsController < ApplicationController
  include ApplicationHelper
  include TextsHelper

  def show
    lang = Language.where("lower(name) LIKE ?", params[:language])[0]
    @word = Word.find_by value: utf8downcase(params[:id]), language_id: lang.id
    if @word
      output = {
        value: @word.value,
        note: @word.note,
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
    lang = Language.where("lower(name) LIKE ?", params[:word][:language])[0]
    @word = Word.find_by value: utf8downcase(params[:id]), language_id: lang.id

    if not @word
      @word = Word.new value: utf8downcase(params[:id]), language_id: lang.id
      @word.save
    end

    params[:word][:language] = lang

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
