class ReaderController < ApplicationController
  before_filter :authenticate_user!
  include ApplicationHelper
  include TextsHelper
  include WordsHelper

  def render_text text
    disabled_words = true if not current_user.real?
    disabled_words = true if current_user.native_language_id == current_language.id

    uniq_words = WordsHelper.raw_words(text).sort.uniq
    notes = Note.find_create_bulk current_language, uniq_words, current_user

    processed_text = process_text text, notes, current_language, disabled_words

    return processed_text
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
