class ReaderController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper
  include WordsHelper

  def render_text text
    text = Text.new content: text, language: current_language
    return text.processed_content current_user
  end

  def index
    @services = Service.where('(language_id=? or language_id=0) and user_id = ? and enabled = true', current_language.id, current_user.id)
    @services = [] if @services == nil

    if params[:q]
      @param_text = render_text params[:q]
      @param_text_raw = params[:q]
    end
  end

  def index_language
    @languages = Language.order(:name).all
  end

  def preview
    render text: render_text(params['text'])
  end
end
