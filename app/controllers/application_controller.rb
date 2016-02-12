class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # this is needed to prevent XHR request form using layouts
  layout proc { false if request.xhr? }

  before_action :redirect_subdomain

  protected

  # always redirect away from the www-version of the site to the plain url one
  def redirect_subdomain
    redirect_to "http://escrit.eu#{request.fullpath}" if request.host == 'www.escrit.eu'
  end

  def after_sign_in_path_for(resource)
    '/home'
  end

  def user_admin!
    redirect_to home_path, alert: 'You must be an administrator to do this!' if not current_user.admin?
  end

  alias_method :devise_current_user, :current_user

  def current_user
    @current_user ||= get_current_user
  end

  private

  def get_current_user
    if !params[:u].blank? && devise_current_user && devise_current_user.admin?
      user = User.find(params[:u])
    end
    user ||= devise_current_user
    unless user.nil?
      user.extend(User::Real)
      user.real = (user.id == devise_current_user.id)
    end
    user
  end
end
