module CalendarAuthenticationConcern
  extend ActiveSupport::Concern

  included do
    before_action :require_google_oauth, only: [:sync]
  end

  private

  def require_google_oauth
    return if current_user.google_connected?

    redirect_to user_google_oauth2_omniauth_authorize_path(prompt: 'consent'),
                alert: 'You need to connect your Google account to manage classes in the calendar.'
  end
end
