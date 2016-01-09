class VocabulariesController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @words = Note.vocabulary_for_review current_user, current_language
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
