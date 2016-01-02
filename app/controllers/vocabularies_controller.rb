class VocabulariesController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @words = Note.includes(:word).joins(:word).where('words.language_id = ? AND vocabulary = TRUE AND ((rating = 0 AND notes.updated_at < ?) OR (rating = 1 AND notes.updated_at < ?) OR (rating = 2 AND notes.updated_at < ?) OR (rating = 3 AND notes.updated_at < ?) OR (rating = 4 AND notes.updated_at < ?) OR ((rating = 5 OR rating = 6) AND notes.updated_at < ?))', current_language.id, 1.days.ago, 2.days.ago, 4.days.ago, 7.days.ago, 14.days.ago, 30.days.ago)
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
