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
    if current_user.compliments.size > 0
      @compliment = current_user.compliments.sample
    else
      @compliment = Compliment.new(value: 'Nice to have you on board!', language: Language.find_by(name: 'English'))
    end
  end
end
