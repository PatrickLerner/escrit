class ServicesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!, only: [ :publish ]

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
    @services = all_services.sort { |a, b|
      l_a = if a.language then a.language.name else "All" end
      l_b = if b.language then b.language.name else "All" end
      if (l_a <=> l_b) != 0
        l_a <=> l_b
      else
        a.name <=> b.name
      end
    }

    public_services = Service.where(user_id: 0)
    @public_services = public_services.sort { |a, b|
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
