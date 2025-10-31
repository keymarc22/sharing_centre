require 'google/apis/calendar_v3'
require 'googleauth'

class GoogleCalendarService
  include Google::Apis::CalendarV3
  
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
  
  attr_reader :service, :user, :impersonated_email
  
  # Initialize the service with either a User (OAuth) or impersonation email
  # @param user [User] User with OAuth tokens (optional if using impersonation)
  # @param impersonated_email [String] Email to impersonate using service account (optional)
  def initialize(user: nil, impersonated_email: nil)
    @user = user
    @impersonated_email = impersonated_email
    @service = CalendarService.new
    @service.client_options.application_name = application_name
    
    # Set authorization
    @service.authorization = if should_use_impersonation?
                              build_service_account_credentials
                            elsif user&.google_oauth_token
                              build_user_credentials
                            else
                              raise ArgumentError, 'Must provide either user with OAuth token or impersonation email'
                            end
  end
  
  # List events from a calendar
  # @param calendar_id [String] The calendar ID
  # @param time_min [Time] Start time for event filtering
  # @param time_max [Time] End time for event filtering
  # @param sync_token [String] Sync token for incremental sync
  # @param max_results [Integer] Maximum number of results
  # @return [Google::Apis::CalendarV3::Events]
  def list_events(calendar_id:, time_min: nil, time_max: nil, sync_token: nil, max_results: 250)
    options = {
      max_results: max_results,
      single_events: true,
      order_by: 'startTime'
    }
    
    if sync_token.present?
      options[:sync_token] = sync_token
      # Remove time filters when using sync token
    else
      options[:time_min] = (time_min || Time.current).iso8601
      options[:time_max] = time_max.iso8601 if time_max
    end
    
    service.list_events(calendar_id, **options)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'list_events')
  end
  
  # Fetch a specific event
  # @param calendar_id [String] The calendar ID
  # @param event_id [String] The event ID
  # @return [Google::Apis::CalendarV3::Event]
  def fetch_event(calendar_id:, event_id:)
    service.get_event(calendar_id, event_id)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'fetch_event')
  end
  
  # List instances of a recurring event
  # @param calendar_id [String] The calendar ID
  # @param recurring_event_id [String] The recurring event ID
  # @param time_min [Time] Start time for event filtering
  # @param time_max [Time] End time for event filtering
  # @return [Google::Apis::CalendarV3::Events]
  def list_instances(calendar_id:, recurring_event_id:, time_min: nil, time_max: nil)
    options = {
      time_min: (time_min || Time.current).iso8601
    }
    options[:time_max] = time_max.iso8601 if time_max
    
    service.list_event_instances(calendar_id, recurring_event_id, **options)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'list_instances')
  end
  
  # Create a new event
  # @param calendar_id [String] The calendar ID
  # @param event_data [Hash] Event data
  # @return [Google::Apis::CalendarV3::Event]
  def create_event(calendar_id:, event_data:)
    event = Event.new(**event_data)
    service.insert_event(calendar_id, event)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'create_event')
  end
  
  # Update an existing event
  # @param calendar_id [String] The calendar ID
  # @param event_id [String] The event ID
  # @param event_data [Hash] Event data
  # @return [Google::Apis::CalendarV3::Event]
  def update_event(calendar_id:, event_id:, event_data:)
    event = Event.new(**event_data)
    service.update_event(calendar_id, event_id, event)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'update_event')
  end
  
  # Delete an event
  # @param calendar_id [String] The calendar ID
  # @param event_id [String] The event ID
  def delete_event(calendar_id:, event_id:)
    service.delete_event(calendar_id, event_id)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'delete_event')
  end
  
  # Watch a calendar for changes
  # @param calendar_id [String] The calendar ID
  # @param params [Hash] Watch parameters (webhook_url, channel_id, expiration)
  # @return [Google::Apis::CalendarV3::Channel]
  def watch_calendar(calendar_id:, params: {})
    channel = Channel.new(
      id: params[:channel_id] || SecureRandom.uuid,
      type: 'web_hook',
      address: params[:webhook_url],
      expiration: params[:expiration] || (Time.current + 7.days).to_i * 1000
    )
    
    service.watch_event(calendar_id, channel)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'watch_calendar')
  end
  
  # Stop watching a channel
  # @param channel_id [String] The channel ID
  # @param resource_id [String] The resource ID
  def stop_watch(channel_id:, resource_id:)
    channel = Channel.new(
      id: channel_id,
      resource_id: resource_id
    )
    
    service.stop_channel(channel)
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'stop_watch')
  end
  
  # List calendars for the authenticated user
  # @return [Google::Apis::CalendarV3::CalendarList]
  def list_calendars
    service.list_calendar_lists
  rescue Google::Apis::ClientError => e
    handle_google_api_error(e, 'list_calendars')
  end
  
  private
  
  # Check if we should use service account impersonation
  def should_use_impersonation?
    impersonation_enabled? && (impersonated_email.present? || user&.email.present?)
  end
  
  # Check if impersonation is enabled in credentials
  def impersonation_enabled?
    service_account_credentials.present? && 
      Rails.application.credentials.dig(:google, :enable_impersonation) == true
  end
  
  # Get service account credentials from Rails credentials
  def service_account_credentials
    @service_account_credentials ||= Rails.application.credentials.dig(:google, :service_account_key_json)
  end
  
  # Build service account credentials with impersonation
  def build_service_account_credentials
    raise 'Service account credentials not found' unless service_account_credentials
    
    email = impersonated_email || user&.email
    raise 'No email provided for impersonation' unless email
    
    credentials = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(service_account_credentials.to_json),
      scope: SCOPE
    )
    
    # Set the subject for domain-wide delegation
    credentials.sub = email
    credentials
  rescue StandardError => e
    Rails.logger.error("Failed to build service account credentials: #{e.message}")
    raise
  end
  
  # Build user OAuth credentials
  def build_user_credentials
    raise 'User OAuth token not found' unless user&.google_oauth_token
    
    # This would need proper OAuth token management
    # For now, we'll use a simple token
    authorizer = Signet::OAuth2::Client.new(
      client_id: Rails.application.credentials.dig(:google, :client_id),
      client_secret: Rails.application.credentials.dig(:google, :client_secret),
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      scope: SCOPE,
      access_token: user.google_oauth_token,
      refresh_token: user.google_refresh_token
    )
    
    # Refresh token if needed
    authorizer.refresh! if authorizer.expired?
    
    # Update user tokens if refreshed
    if authorizer.access_token != user.google_oauth_token
      user.update(
        google_oauth_token: authorizer.access_token,
        google_refresh_token: authorizer.refresh_token
      )
    end
    
    authorizer
  rescue StandardError => e
    Rails.logger.error("Failed to build user credentials: #{e.message}")
    raise
  end
  
  # Get application name from credentials
  def application_name
    Rails.application.credentials.dig(:google, :application_name) || 'Sharing Centre'
  end
  
  # Handle Google API errors
  def handle_google_api_error(error, operation)
    case error.status_code
    when 410
      # Sync token invalid - need full sync
      Rails.logger.warn("Sync token invalid for #{operation}")
      raise SyncTokenInvalidError, 'Sync token is no longer valid'
    when 404
      Rails.logger.warn("Resource not found for #{operation}")
      nil
    when 403
      Rails.logger.error("Permission denied for #{operation}: #{error.message}")
      raise PermissionDeniedError, "Permission denied: #{error.message}"
    else
      Rails.logger.error("Google API error in #{operation}: #{error.message}")
      raise
    end
  end
  
  # Custom error classes
  class SyncTokenInvalidError < StandardError; end
  class PermissionDeniedError < StandardError; end
end
