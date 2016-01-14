class ArtworksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!
  
  def index_language
    @languages = Language.order(:name).all
  end

  def create
    @artwork = Artwork.new(artwork_params)
 
    if @artwork.save
      redirect_to edit_artwork_path(@artwork), notice: 'New artwork has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
    @artwork = Artwork.find_by id: params[:id]
  end

  def destroy
    @artwork = Artwork.find_by id: params[:id]
    @artwork.destroy
   
    redirect_to artworks_path, notice: 'Artwork has been successfully deleted.'
  end

  def index
    lang = Language.where("lower(name) = ?", params[:language].downcase)[0]
    @artworks = lang.artworks.joins(:language).order('languages.name asc')
  end

  def new
    @artwork = Artwork.new
  end

  def update
    @artwork = Artwork.find_by id: params[:id]
   
    if @artwork.update(artwork_params)
      redirect_to edit_artwork_path(@artwork), notice: 'Artwork has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def artwork_params
      params.require(:artwork).permit(:image, :language_id)
    end
end
