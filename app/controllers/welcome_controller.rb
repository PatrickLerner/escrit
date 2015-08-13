class WelcomeController < ApplicationController
  def index
    @languages = Language.order('name asc').all
  end

  def cookie_policy
  end

  def legal_notice
  end
end
