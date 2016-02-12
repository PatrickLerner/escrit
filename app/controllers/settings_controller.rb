class SettingsController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!

  helper_method :vocabulary

  def index
  end

  def show
    if params[:do] == 'reset'
      Note.vocabulary(current_user, current_language).update_all(vocabulary: false)
    elsif params[:do] == 'shuffle'
      Note.shuffle_vocabulary!(current_user, current_language)
    end

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

  def vocabulary
    current_user.languages.map { |language|
      vocab_count = Note.vocabulary_count current_user, language
      [language, vocab_count]
    }.select { |i| i[1] > 0 }
  end
end
