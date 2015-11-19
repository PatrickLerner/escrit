class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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
end
