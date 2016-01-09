class LanguagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!

  def create
    @language = Language.new(language_params)
 
    if @language.save
      redirect_to languages_path, notice: 'New language has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
    @language = Language.where("lower(name) = ?", params[:id].downcase)[0]
  end

  def destroy
    @language = Language.find(params[:id])
    @language.destroy
   
    redirect_to languages_path, notice: 'Language has been successfully deleted.'
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
      redirect_to languages_path, notice: 'Language has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def language_params
      params.require(:language).permit(:name)
    end
end
