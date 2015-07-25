class LanguagesController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    redirect_to settings_path if not current_user.admin?

    @language = Language.new(language_params)
 
    if @language.save
      redirect_to languages_path
    else
      render 'new'
    end
  end

  def edit
    redirect_to settings_path if not current_user.admin?

    @language = Language.where("lower(name) LIKE ?", params[:id])[0]
  end

  def destroy
    redirect_to settings_path if not current_user.admin?

    @language = Language.find(params[:id])
    @language.destroy
   
    redirect_to languages_path
  end

  def index
    redirect_to settings_path if not current_user.admin?

    @languages = Language.order(:name)
  end

  def new
    redirect_to settings_path if not current_user.admin?

    @language = Language.new
  end

  def update
    redirect_to settings_path if not current_user.admin?
    
    @language = Language.find(params[:id])
   
    if @language.update(language_params)
      redirect_to languages_path
    else
      render 'edit'
    end
  end

  private
    def language_params
      params.require(:language).permit(:name)
    end
end
