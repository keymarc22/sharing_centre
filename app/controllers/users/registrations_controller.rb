class Users::RegistrationsController < Devise::RegistrationsController
  layout 'application', only: [:edit, :update]

  protected

  def after_update_path_for(_resource)
    edit_user_registration_path
  end

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end
end
