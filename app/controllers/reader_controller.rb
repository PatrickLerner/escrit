class ReaderController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :load_services, only: [:index]

  def index
    if params[:q]
      @param_text = render_text params[:q]
      @param_text_raw = params[:q]
    end
  end

  def preview
    render plain: render_text(params['text'])
  end

  private

  def render_text(text)
    text = Text.new content: text, language: current_language

    text.processed_content current_user
  end
end
