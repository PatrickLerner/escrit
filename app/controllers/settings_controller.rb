class SettingsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
  end

  def show
    @user = current_user
    render template: "settings/#{params[:page]}"
  end

  def update
    @user = current_user
    @user.update(user_params)
    redirect_to settings_path
  end

  private
    def user_params
      params.require(:user).permit(:audio_rate)
    end
end
