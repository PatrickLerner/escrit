class CategoriesController < ApplicationController
  include ApplicationHelper
  using StringRefinements
  
  before_action :authenticate_user!

  def edit
    @text = Text.find_by id: params[:id]
    @total_texts = Text.where(
      category: @text.category,
      language: @text.language,
      public: @text.public,
      hidden: @text.hidden
    ).count
  end

  def autocomplete_text_category
    term = params[:term]
    texts = Text.where(
      'lower(category) like ? and (user_id = ? or public = true) ' \
      'and language_id = ?',
      "%#{term.utf8downcase}%",
      current_user.id,
      current_language.id
    ).group('category').select('category').order('category asc').limit(5)
    
    render text: texts.map(&:category).to_json
  end
end
