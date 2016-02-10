class ServicesController < ApplicationController
  before_action :authenticate_user!
  before_action :user_admin!, only: [ :publish ]

  def create
    @service = Service.new(service_params)
    @service.user_id = current_user.id
 
    if @service.save
      redirect_to services_path, notice: 'New service has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
    if current_user.admin?
      @service = Service.find_by id: params[:id]
    else
      @service = Service.find_by id: params[:id], user_id: current_user.id
    end
  end

  def publish
    @service = Service.find_by id: params[:id], user_id: current_user.id
    Service.create name: @service.name, short_name: @service.short_name, url: @service.url, language_id: @service.language_id, user_id: 0, enabled: true
    redirect_to services_path
  end

  def copy
    @service = Service.find_by id: params[:id], user_id: 0
    Service.create name: @service.name, short_name: @service.short_name, url: @service.url, language_id: @service.language_id, user_id: current_user.id, enabled: true
    redirect_to services_path
  end

  def destroy
    if current_user.admin?
      @service = Service.find_by id: params[:id]
    else
      @service = Service.find_by id: params[:id], user_id: current_user.id
    end
    @service.destroy
   
    redirect_to services_path, notice: 'Service has been successfully deleted.'
  end

  def index
    all_services = Service.where(user_id: current_user.id)
    @services = all_services.sort

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
    if current_user.admin?
      @service = Service.find_by id: params[:id]
    else
      @service = Service.find_by id: params[:id], user_id: current_user.id
    end
    
    if @service.update(service_params)
      redirect_to services_path, notice: 'Service has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def service_params
      params.require(:service).permit(:name, :short_name, :url, :language_id, :enabled)
    end
end
