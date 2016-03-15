class VocabularyController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper

  def index
    @words = Note.vocabulary.for_user(current_user)
                 .for_language(current_language).awaiting_review
    respond_to do |format|
      format.html
      format.json do
        render json: @words.map(&:word).map(&:value)
      end
    end
  end
end
