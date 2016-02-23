class ArtworksController < ApplicationController
  include LanguageIndexPage
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :restrict_access!
  before_action :load_artwork, only: [:show, :edit, :destroy, :update]

  def create
    @artwork = Artwork.new(artwork_params)

    return render 'new' unless @artwork.save

    redirect_to edit_language_artwork_path(@artwork.language, @artwork),
                notice: 'New artwork has been successfully added.'
  end

  def edit
  end

  def destroy
    @artwork.destroy

    redirect_to artworks_path, notice: 'Artwork has been successfully deleted.'
  end

  def index
    @artworks = current_language.artworks
  end

  def new
    @artwork = Artwork.new
  end

  def update
    return render 'edit' unless @artwork.update(artwork_params)

    redirect_to edit_language_artwork_path(@artwork.language, @artwork),
                notice: 'Artwork has been successfully updated.'
  end

  private

  def restrict_access!
    authorize! :manage, Artwork
  end

  def load_artwork
    @artwork = Artwork.find_by id: params[:id]
  end

  def artwork_params
    params.require(:artwork).permit(:image, :language_id)
  end
end
