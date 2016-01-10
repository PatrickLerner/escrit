class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # this is needed to prevent XHR request form using layouts
  layout proc { false if request.xhr? }

  before_filter :redirect_subdomain

  # always redirect away from the www-version of the site to the plain url one
  def redirect_subdomain
    if request.host == 'www.escrit.eu'
      redirect_to 'http://escrit.eu' + request.fullpath
    end
  end

  def after_sign_in_path_for(resource)
    '/home'
  end

  # converts a utf8 string into lower case
  # (probably depricated)
  def utf8downcase text
    text.mb_chars.downcase.to_s
  end

  def self.utf8downcase text
    text.mb_chars.downcase.to_s
  end

  def user_admin!
    redirect_to home_path, alert: 'You must be an administrator to do this!' if not current_user.admin?
  end

  alias_method :devise_current_user, :current_user
  def current_user
    if params[:user].blank? && devise_current_user.admin?
      user = devise_current_user
    else
      user = User.find(params[:user])
      user.real = false
    end
    user
  end
end
