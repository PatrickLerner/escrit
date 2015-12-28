class WelcomeController < ApplicationController
  before_filter :authenticate_user!, only: [ :home ]

  def index
    @languages = Language.order('name asc').all
  end

  def cookie_policy
  end

  def legal_notice
  end

  def home
    @user = current_user
  end
end
