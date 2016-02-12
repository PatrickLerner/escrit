class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :user_admin!, only: [:publish]
  before_action :load_service, only: [:edit, :publish, :destroy, :update]

  def create
    @service = Service.new(service_params)
    @service.user = current_user

    return render 'new' unless @service.save
    
    redirect_to services_path, notice: 'New service has been successfully added.'
  end

  def edit
  end

  def publish
    @new_service = @service.dup
    @new_service.user_id = 0
    @new_service.save
    
    redirect_to services_path
  end

  def copy
    @service = Service.find_by id: params[:id], user_id: 0
    
    @new_service = @service.dup
    @new_service.user = current_user
    @new_service.save
    
    redirect_to services_path
  end

  def destroy
    @service.destroy
   
    redirect_to services_path, notice: 'Service has been successfully deleted.'
  end

  def index
    @services = Service.where(user_id: current_user.id).sort
    @public_services = Service.where(user_id: 0)

    @services.each do |service|
      service.published = @public_services.include?(service)
    end

    @public_services = @public_services.reject do |public_service|
      @services.include? public_service
    end

    @public_services = @public_services.sort
  end

  def new
    @service = Service.new
    @service.enabled = true
  end

  def update    
    if @service.update(service_params)
      redirect_to services_path, notice: 'Service has been successfully updated.'
    else
      render 'edit'
    end
  end

  private

  def load_service
    if current_user.admin?
      @service = Service.find_by id: params[:id]
    else
      @service = Service.find_by id: params[:id], user_id: current_user.id
    end
  end

  def service_params
    params.require(:service).permit(
      :name, :short_name, :url, :language_id, :enabled
    )
  end
end
