class ComplimentsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @compliment = Compliment.new(compliment_params)
 
    if @compliment.save
      redirect_to compliments_path
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
   
    redirect_to compliments_path
  end

  def index
    @compliments = Compliment.all
  end

  def new
    @compliment = Compliment.new
  end

  def update
    @compliment = Compliment.find_by id: params[:id]
   
    if @compliment.update(compliment_params)
      redirect_to compliments_path
    else
      render 'edit'
    end
  end

  private
    def compliment_params
      params.require(:compliment).permit(:value, :language_id)
    end
end
