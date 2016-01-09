class ReplacementsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!

  def create
    @replacement = Replacement.new(replacement_params)
 
    if @replacement.save
      redirect_to replacements_path, notice: 'New replacement has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
    @replacement = Replacement.find_by id: params[:id]
  end

  def destroy
    @replacement = Replacement.find(params[:id])
    @replacement.destroy
   
    redirect_to replacements_path, notice: 'Replacement has been successfully deleted.'
  end

  def index
    @replacements = Replacement.order(:language_id)
  end

  def new
    @replacement = Replacement.new
  end

  def update
    @replacement = Replacement.find_by id: params[:id]
   
    if @replacement.update(replacement_params)
      redirect_to replacements_path, notice: 'Replacement has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def replacement_params
      params.require(:replacement).permit(:replacement, :value, :language_id)
    end
end
