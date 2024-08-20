class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    # This needs to be implemented in the user model
    @user = User.from_omniauth(auth)

    if @user.present?
      sign_out_all_scopes # existing user signed out
      flash[:success] = t 'devise_omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect @user, event: :authentication # authenticated user signed in
    else
      flash[:alert] = t 'devise_omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized"
      redirect_to_new_user_session_path
    end


    # if @user.persisted?
    #   sign_in_and_redirect @user, event: :authentication
    #   set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    # else
    #   session['devise.google_data'] = request.env['omniauth.auth'].except('extra')
    #   redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    # end
  end

  # def failure
  #   redirect_to root_path
  # end

  private

  # #auth utilizes memoization ( auth ||= ...) to efficiently access OmniAuth data from the request environment, preventing unnecessary repeated calls
  def auth
    auth ||= request.env['omniauth.auth']
  end
end
