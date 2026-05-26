class GoogleCalendarService
  CALENDAR_ID = 'primary'

  def initialize(user)
    @user = user
  end

  def create_event(event_params)
    event = Google::Apis::CalendarV3::Event.new
    event_params.each { |key, value| event.send("#{key}=", value) }
    client.insert_event(CALENDAR_ID, event, conference_data_version: 1)
  rescue Google::Apis::Error => e
    Rails.logger.error("Google Calendar create_event error: #{e.message}")
    raise e
  end

  def update_event(google_event_id, event_params)
    event = Google::Apis::CalendarV3::Event.new
    event_params.each { |key, value| event.send("#{key}=", value) }
    client.update_event(CALENDAR_ID, google_event_id, event)
  rescue Google::Apis::Error => e
    Rails.logger.error("Google Calendar update_event error: #{e.message}")
    raise e
  end

  def delete_event(google_event_id)
    client.delete_event(CALENDAR_ID, google_event_id)
  rescue Google::Apis::Error => e
    Rails.logger.error("Google Calendar delete_event error: #{e.message}")
    raise e
  end

  def list_events(time_min:, time_max:)
    client.list_events(
      CALENDAR_ID,
      time_min: time_min,
      time_max: time_max,
      show_deleted: false,
      single_events: true
    ).items || []
  rescue Google::Apis::Error => e
    Rails.logger.error("Google Calendar list_events error: #{e.message}")
    raise e
  end

  private

  def client
    @client ||= Google::Apis::CalendarV3::CalendarService.new.tap do |service|
      service.authorization = authorizer
    end
  end

  def authorizer
    raise Google::Auth::AuthorizationError, "User #{@user.id} has no Google refresh token. Re-authenticate via Google OAuth." if @user.google_refresh_token.blank?

    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: Rails.application.credentials.google_oauth_client_id,
      client_secret: Rails.application.credentials.google_oauth_client_secret,
      access_token: @user.google_access_token,
      refresh_token: @user.google_refresh_token,
      scope: 'https://www.googleapis.com/auth/calendar',
      expires_at: @user.google_token_expires_at&.to_i
    )

    if credentials.expired?
      credentials.refresh!
      @user.update_columns(
        google_access_token: credentials.access_token,
        google_token_expires_at: Time.at(credentials.expires_at.to_i)
      )
    end

    credentials
  end
end
