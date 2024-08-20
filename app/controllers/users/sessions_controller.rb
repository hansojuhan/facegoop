# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # Determines the path where the user is redirected after signing out of the application
  # By default, Devise redirects users to the root path after signing out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  
  # Determines the path where the user is redirected after successfully signing in
  # Checks for stored location (URL a user tried to access before redirect)
  # If no stored location, redirects to root
  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
