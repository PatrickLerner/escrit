class DictationsController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @note = Note.joins(:word).where(
      'words.language_id = ? AND user_id = ? AND vocabulary = true',
      current_language.id,
      current_user.id
    ).order("RANDOM()").first()
    
    respond_to do |format|
      format.html
      format.json {
        if @note
          render json: {
            value: @note.word.value,
            value_clean: @note.word.value_clean,
            note: @note.value.strip,
            language: @note.word.language.name,
            rating: @note.rating,
            vocabulary: @note.vocabulary?
          }
        else
          render json: {}
        end
      }
    end
  end
end
