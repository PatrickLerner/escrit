class ArtworksController < ApplicationController
  include ApplicationHelper
  
  before_action :authenticate_user!
  before_action :user_admin!
  before_action :load_artwork, only: [ :show, :edit, :destroy, :update ]

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
  end

  def destroy
    @artwork.destroy
   
    redirect_to artworks_path, notice: 'Artwork has been successfully deleted.'
  end

  def index
    @artworks = current_language.artworks.joins(:language).order('languages.name asc')
  end

  def new
    @artwork = Artwork.new
  end

  def update
    if @artwork.update(artwork_params)
      redirect_to edit_artwork_path(@artwork), notice: 'Artwork has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def load_artwork
      @artwork = Artwork.find_by id: params[:id]
    end
    
    def artwork_params
      params.require(:artwork).permit(:image, :language_id)
    end
end
