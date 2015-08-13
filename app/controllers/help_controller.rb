class HelpController < ApplicationController
  def index
  end
  
  def show
    render template: "help/#{params[:page]}"
  end
end
