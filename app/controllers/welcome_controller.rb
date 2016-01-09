class WelcomeController < ApplicationController
  before_filter :authenticate_user!, only: [ :home ]

  def index
    @languages = Language.order('name asc').all
    redirect_to home_path if user_signed_in?
  end

  def cookie_policy
  end

  def legal_notice
  end

  def home
    @user = current_user
    @compliment = current_user.compliments.sample
  end
end
