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
    render text: Text.group('category').where(
      'lower(category) like ? and (user_id = ? or public = true) ' \
      'and language_id = ?', "%#{params[:term].utf8downcase}%",
      current_user.id,
      current_language.id
    ).order('category asc').limit(5).pluck(:category).to_json
  end
end
