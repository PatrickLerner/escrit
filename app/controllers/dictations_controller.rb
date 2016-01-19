class DictationsController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @word = Note.joins(:word).where('words.language_id = ? AND user_id = ? AND vocabulary = true', current_language.id, current_user.id).order("RANDOM()").first()
    respond_to do |format|
      format.html
      format.json {
        render json: {
          value: @word.word.value,
          value_clean: @word.word.value_clean,
          note: @word.value.strip,
          language: @word.word.language.name,
          rating: @word.rating,
          vocabulary: @word.vocabulary == true
        }
      }
    end
  end
end
