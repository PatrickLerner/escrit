class ArtworksController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @artwork = Artwork.new(artwork_params)
 
    if @artwork.save
      redirect_to edit_artwork_path(@artwork)
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
   
    redirect_to artworks_path
  end

  def index
    @artworks = Artwork.joins(:language).order('languages.name asc').all
  end

  def new
    @artwork = Artwork.new
  end

  def update
    @artwork = Artwork.find_by id: params[:id]
   
    if @artwork.update(artwork_params)
      redirect_to edit_artwork_path(@artwork)
    else
      render 'edit'
    end
  end

  private
    def artwork_params
      params.require(:artwork).permit(:image, :language_id)
    end
end
