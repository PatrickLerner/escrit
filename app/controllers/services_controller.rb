class ServicesController < ReadScaffoldController
  resource Service

  def show
    unless current_language.present?
      render json: { error: 'language not found' }, status: :not_found
    end
  end

  protected

  def load_object
    collection.first
  end

  def collection
    Service.for_user(current_user).for_language(current_language)
  end

  def current_language
    Language.find_by(id: params[:id])
  end
end
