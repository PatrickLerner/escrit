class VocabulariesController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @words = Note.includes(:word).joins(:word).where('notes.user_id = ? AND words.language_id = ? AND vocabulary = TRUE AND rating < 6 AND notes.review_at < ?', current_user.id, current_language.id, DateTime.now)
    respond_to do |format|
      format.html
      format.json {
        if @words
          render json: @words.map { |word|
            word.word.value
          }
        else
          render json: []
        end
      }
    end
  end
end
