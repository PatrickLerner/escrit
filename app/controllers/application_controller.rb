class ApplicationController < ActionController::Base
  helper :all

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :set_csrf_cookie_for_ng
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action :redirect_subdomain

  protected

  # always redirect away from the www-version of the site to the plain url one
  def redirect_subdomain
    if request.host == 'www.escrit.eu'
      redirect_to "http://escrit.eu#{request.fullpath}"
    end
  end

  def authenticate_user!
    return unless current_user.nil?
    return unless request.format == :json
    return if controller_name.in? %w(sessions registrations passwords)
    render json: { error: 'authentication error' }, status: 401
  end

  def verified_request?
    super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }
  end
end
