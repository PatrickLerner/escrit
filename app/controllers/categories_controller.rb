class CategoriesController < ReadScaffoldController
  resource Category

  protected

  def collection
    @collection ||= resource.includes(:language).where(user: current_user)
  end
end
