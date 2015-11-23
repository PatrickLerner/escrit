class CategoriesController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @text = Text.find_by id: params[:id]
    @total_texts = Text.where(category: @text.category, language_id: @text.language_id, public: @text.public, hidden: @text.hidden).count
  end
end
