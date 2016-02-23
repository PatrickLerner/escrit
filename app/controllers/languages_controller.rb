class LanguagesController < ApplicationController
  before_action :authenticate_user!
  before_action :restrict_access!
  before_action :load_language, only: [:edit, :destroy, :update]
  before_action :invalidate_cache, only: [:update, :destroy]

  def create
    @language = Language.new(language_params)

    return render 'new' unless @language.save

    redirect_to languages_path,
                notice: 'New language has been successfully added.'
  end

  def edit
  end

  def destroy
    @language.destroy

    redirect_to languages_path,
                notice: 'Language has been successfully deleted.'
  end

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def update
    return render 'edit' unless @language.update(language_params)

    redirect_to languages_path,
                notice: 'Language has been successfully updated.'
  end

  private

  def restrict_access!
    authorize! :manage, Language
  end

  def invalidate_cache
    Rails.cache.fetch("language_#{@language.name.downcase}")
  end

  def load_language
    @language = Language.find params[:id]
  end

  def language_params
    params.require(:language).permit(:name, :voice, :voice_rate)
  end
end
