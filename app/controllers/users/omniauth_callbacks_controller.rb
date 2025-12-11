class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    if auth.nil?
      flash[:alert] = t('devise.omniauth_callbacks.failure')
      return redirect_to new_user_session_path
    end
    
    handle_response GoogleOauthService.authorize!(auth)
  rescue OmniauthInvalidError => _err
    flash[:alert] = t('devise.omniauth_callbacks.no_email')
    session['devise.omniauth_data'] = auth.except('extra') if auth.respond_to?(:except)
    return redirect_to new_user_session_path
  end

  private
  
  def auth
    @auth ||= request.env['omniauth.auth']
  end
  
  def handle_response(user)
    if user.present?
      sign_out_all_scopes
      flash[:notice] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      sign_in_and_redirect user, event: :authentication
    else
      flash[:alert] = t('devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info&.email} is not authorized.")
      redirect_to new_user_session_path
    end
  end
end