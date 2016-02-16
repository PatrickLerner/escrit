class RegistrationController < Devise::RegistrationsController
  after_filter :add_account, only: [:create]

  protected

  def add_account
    # user is created successfuly
    return unless resource.persisted?
    # add all services that are public by default
    Service.published.each do |service|
      service.dup_for(resource)
    end
  end

  def after_update_path_for(resource)
    "/u/#{resource.id}"
  end

  def after_sign_up_path_for(_resource)
    home_path
  end

  private

  def sign_up_params
    params.require(:user).permit(
      :name, :email, :password, :password_confirmation, :native_language_id
    )
  end

  def account_update_params
    params.require(:user).permit(
      :name, :about, :email, :password, :password_confirmation,
      :current_password, :native_language_id
    )
  end
end
