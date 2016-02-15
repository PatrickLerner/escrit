class DictationsController < ApplicationController
  include ApplicationHelper

  def index_language
    @languages = Language.order(:name).all
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: Note.sample_vocabulary(current_user, current_language)
          .try(:to_json) || {}
      end
    end
  end
end
