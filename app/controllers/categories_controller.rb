class CategoriesController < ApplicationController
  using StringRefinements
  
  before_filter :authenticate_user!

  def edit
    @text = Text.find_by id: params[:id]
    @total_texts = Text.where(category: @text.category, language: @text.language, public: @text.public, hidden: @text.hidden).count
  end

  def autocomplete_text_category
    term = params[:term]
    lang = Language.where("lower(name) = ?", params[:lang].downcase)[0]
    texts = Text.where('lower(category) like ? and (user_id = ? or public = true) and language_id = ?', "%#{term.utf8downcase}%", current_user.id, lang.id).group('category').select('category').order('category asc').limit(5)
    cats = texts.map { |t| t.category }
    render text: cats.to_json
  end
end
