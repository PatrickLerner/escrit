class LanguageartworksController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @languageartwork = LanguageArtwork.new(languageartwork_params)
 
    if @languageartwork.save
      redirect_to edit_languageartwork_path(@languageartwork)
    else
      render 'new'
    end
  end

  def edit
    @languageartwork = LanguageArtwork.find_by id: params[:id]
  end

  def destroy
    @languageartwork = LanguageArtwork.find_by id: params[:id]
    @languageartwork.destroy
   
    redirect_to languageartworks_path
  end

  def index
    @languageartworks = LanguageArtwork.joins(:language).order('languages.name asc').all
  end

  def new
    @languageartwork = LanguageArtwork.new
  end

  def update
    @languageartwork = LanguageArtwork.find_by id: params[:id]
   
    if @languageartwork.update(languageartwork_params)
      redirect_to edit_languageartwork_path(@languageartwork)
    else
      render 'edit'
    end
  end

  private
    def languageartwork_params
      params.require(:languageartwork).permit(:image, :language_id)
    end
end
