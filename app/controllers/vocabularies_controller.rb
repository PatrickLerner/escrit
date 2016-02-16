class VocabulariesController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    @words = Note.vocabulary.for_user(current_user)
                 .for_language(current_language).awaiting_review
    respond_to do |format|
      format.html
      format.json {
        if @words.empty?
          render json: []
        else
          render json: @words.map { |word|
            word.word.value
          }
        end
      }
    end
  end
end
