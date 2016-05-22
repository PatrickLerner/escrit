class ScaffoldController < ReadScaffoldController
  before_action :check_permission_object!, only: [:update, :destroy]
  before_action :check_permission_resource!, only: [:create]

  def create
    if (@object ||= resource.new(permitted_params)).save
      render :show, formats: :json, status: :created
    else
      render json: object.errors, status: :unprocessable_entity
    end
  end

  def update
    if object.update(permitted_params)
      render :show, status: :ok
    else
      render json: object.errors, status: :unprocessable_entity
    end
  end

  def destroy
    object.destroy
    head :no_content
  end

  protected

  def check_permission_object!
    authorize! action_name.to_sym, object
  end

  def check_permission_resource!
    authorize! action_name.to_sym, resource
  end

  def permitted_params
    {}
  end
end
