class LanguagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_admin!

  before_action :load_language, only: [ :edit, :destroy, :update ]

  def create
    @language = Language.new(language_params)
    if @language.save
      redirect_to languages_path, notice: 'New language has been successfully added.'
    else
      render 'new'
    end
  end

  def edit
  end

  def destroy
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
    if @language.update(language_params)
      redirect_to languages_path, notice: 'Language has been successfully updated.'
    else
      render 'edit'
    end
  end

  private
    def load_language
      @language = Language.find params[:id]
    end

    def language_params
      params.require(:language).permit(:name, :voice, :voice_rate)
    end
end
