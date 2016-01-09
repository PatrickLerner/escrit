class ComplimentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!
    
  def create
    @compliment = Compliment.new(compliment_params)
 
    if @compliment.save
      redirect_to compliments_path, notice: 'New compliment has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
    @compliment = Compliment.find_by id: params[:id]
  end

  def destroy
    @compliment = Compliment.find_by id: params[:id]
    @compliment.destroy
   
    redirect_to compliments_path, notice: 'Compliment has been successfully deleted.'
  end

  def index
    @compliments = Compliment.joins(:language).order('languages.name asc, value asc').all
  end

  def new
    @compliment = Compliment.new
  end

  def update
    @compliment = Compliment.find_by id: params[:id]
   
    if @compliment.update(compliment_params)
      redirect_to compliments_path, notice: 'Compliment has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def compliment_params
      params.require(:compliment).permit(:value, :language_id)
    end
end
