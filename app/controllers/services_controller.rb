class ServicesController < ApplicationController
  def create
    @service = Service.new(service_params)
 
    if @service.save
      redirect_to services_path
    else
      render 'new'
    end
  end

  def edit
    @service = Service.find_by :id => params[:id]
  end

  def destroy
    @service = Service.find_by :id => params[:id]
    @service.destroy
   
    redirect_to services_path
  end

  def index
    @services = Service.order(:name)
  end

  def new
    @service = Service.new
  end

  def update
    @service = Service.find_by :id => params[:id]
   
    if @service.update(service_params)
      redirect_to services_path
    else
      render 'edit'
    end
  end

  private
    def service_params
      params.require(:service).permit(:name, :short_name, :url, :language_id)
    end
end
