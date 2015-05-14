class LanguagesController < ApplicationController
  def create
    @language = Language.new(language_params)
 
    if @language.save
      redirect_to languages_path
    else
      render 'new'
    end
  end

  def edit
    @language = Language.find(params[:id])
  end

  def destroy
    @language = Language.find(params[:id])
    @language.destroy
   
    redirect_to languages_path
  end

  def index
    @languages = Language.order(:name)
  end

  def new
    @language = Language.new
  end

  def update
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
