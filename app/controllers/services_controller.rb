class ServicesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @service = Service.new(service_params)
    @service.user_id = current_user.id
 
    if @service.save
      redirect_to services_path
    else
      render 'new'
    end
  end

  def edit
    @service = Service.find_by id: params[:id], user_id: current_user.id
  end

  def destroy
    @service = Service.find_by id: params[:id], user_id: current_user.id
    @service.destroy
   
    redirect_to services_path
  end

  def index
    all_services = Service.where(user_id: current_user.id)
    @services = all_services.sort { |a, b|
      l_a = if a.language then a.language.name else "All" end
      l_b = if b.language then b.language.name else "All" end
      if (l_a <=> l_b) != 0
        l_a <=> l_b
      else
        a.name <=> b.name
      end
    }
  end

  def new
    @service = Service.new
  end

  def update
    @service = Service.find_by id: params[:id], user_id: current_user.id
   
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
