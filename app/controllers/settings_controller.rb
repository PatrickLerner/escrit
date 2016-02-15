class SettingsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update]
  helper_method :vocabulary

  def index
  end

  def show
    if params[:do] == 'reset'
      Note.vocabulary(current_user, current_language)
          .update_all(vocabulary: false)
    elsif params[:do] == 'shuffle'
      Note.shuffle_vocabulary!(current_user, current_language)
    end
    render template: "settings/#{params[:page]}"
  end

  def update
    @user.update(user_params)
    redirect_to settings_path
  end

  private

  def set_user
    @user ||= current_user
  end

  def user_params
    params.require(:user).permit(:audio_rate)
  end

  def vocabulary
    all_vocabulary = current_user.languages.map do |language|
      [language, Note.vocabulary(current_user, language).count]
    end
    all_vocabulary.select { |i| i[1] > 0 }
  end
end
