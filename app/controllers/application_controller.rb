class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # this is needed to prevent XHR request form using layouts
  layout proc { false if request.xhr? }

  before_action :redirect_subdomain

  protected

  def load_services
    @services = Service.for_user(current_user)
                       .for_language(current_language).enabled
  end

  # always redirect away from the www-version of the site to the plain url one
  def redirect_subdomain
    if request.host == 'www.escrit.eu'
      redirect_to "http://escrit.eu#{request.fullpath}"
    end
  end

  def after_sign_in_path_for(_resource)
    '/home'
  end

  def user_admin!
    unless current_user.admin?
      redirect_to home_path, alert: 'You must be an administrator to do this!'
    end
  end

  alias_method :devise_current_user, :current_user

  def current_user
    @current_user ||= determine_current_user
  end

  private

  def determine_current_user
    if allowed_to_shadow_users? && params[:u].present?
      user = User.find(params[:u])
    end
    user ||= devise_current_user
    unless user.nil?
      user.extend(User::Real)
      user.real = (user.id == devise_current_user.id)
    end
    user
  end

  def allowed_to_shadow_users?
    devise_current_user.try(:admin?)
  end
end
