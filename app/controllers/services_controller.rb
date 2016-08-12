class ServicesController < ScaffoldController
  resource Service

  def create
    @object ||= resource.new(try_permitted_params)
    @object.user = current_user
    super
  end

  protected

  def load_object
    collection.find_by(resource.param_field => params[:id])
  end

  def collection
    Service.for_user(current_user).includes(:language)
  end

  def permitted_params
    params.require(:service).permit(
      :id, :name, :short_name, :url, :language_id, :enabled
    )
  end
end
