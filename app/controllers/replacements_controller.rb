class ReplacementsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    redirect_to settings_path if not current_user.admin?

    @replacement = Replacement.new(replacement_params)
 
    if @replacement.save
      redirect_to replacements_path
    else
      render 'new'
    end
  end

  def edit
    redirect_to settings_path if not current_user.admin?

    @replacement = Replacement.find_by id: params[:id]
  end

  def destroy
    redirect_to settings_path if not current_user.admin?

    @replacement = Replacement.find(params[:id])
    @replacement.destroy
   
    redirect_to replacements_path
  end

  def index
    redirect_to settings_path if not current_user.admin?

    @replacements = Replacement.order(:language_id)
  end

  def new
    redirect_to settings_path if not current_user.admin?

    @replacement = Replacement.new
  end

  def update
    redirect_to settings_path if not current_user.admin?
    
    @replacement = Replacement.find_by id: params[:id]
   
    if @replacement.update(replacement_params)
      redirect_to replacements_path
    else
      render 'edit'
    end
  end

  private
    def replacement_params
      params.require(:replacement).permit(:replacement, :value, :language_id)
    end
end
