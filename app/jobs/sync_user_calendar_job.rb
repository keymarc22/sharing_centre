class SyncUserCalendarJob < ApplicationJob
  queue_as :default
  
  # Sync a user's calendar events
  # @param google_calendar_id [Integer] The GoogleCalendar record ID
  # @param force_full_sync [Boolean] Force a full sync (ignore sync token)
  def perform(google_calendar_id, force_full_sync: false)
    google_calendar = GoogleCalendar.find(google_calendar_id)
    user = google_calendar.user
    calendar_id = google_calendar.calendar_id
    
    Rails.logger.info("Starting calendar sync for user #{user.email}, calendar #{calendar_id}")
    
    # Initialize Google Calendar service
    service = GoogleCalendarService.new(
      user: user,
      impersonated_email: user.email
    )
    
    # Determine sync parameters
    sync_token = force_full_sync ? nil : google_calendar.sync_token
    time_min = sync_token.present? ? nil : 1.month.ago
    time_max = sync_token.present? ? nil : 3.months.from_now
    
    begin
      # Fetch events from Google Calendar
      events_result = service.list_events(
        calendar_id: calendar_id,
        time_min: time_min,
        time_max: time_max,
        sync_token: sync_token
      )
      
      # Process each event
      events_count = 0
      events_result.items.each do |event|
        next if event.status == 'cancelled' && event.id.blank?
        
        ClassSession.sync_from_google_event(
          event.to_h.deep_stringify_keys,
          owner_user: user,
          owner_calendar_id: calendar_id
        )
        events_count += 1
      rescue StandardError => e
        Rails.logger.error("Failed to sync event #{event.id}: #{e.message}")
      end
      
      # Update sync token if available
      if events_result.next_sync_token.present?
        google_calendar.update_sync_token!(events_result.next_sync_token)
      else
        google_calendar.update!(last_synced_at: Time.current)
      end
      
      Rails.logger.info("Completed calendar sync for user #{user.email}: #{events_count} events processed")
      
    rescue GoogleCalendarService::SyncTokenInvalidError => e
      # Sync token is invalid, retry with full sync
      Rails.logger.warn("Sync token invalid for calendar #{calendar_id}, retrying with full sync")
      google_calendar.clear_sync_token!
      
      # Retry with full sync
      if force_full_sync
        raise # Already doing full sync, don't retry infinitely
      else
        perform(google_calendar_id, force_full_sync: true)
      end
      
    rescue StandardError => e
      Rails.logger.error("Failed to sync calendar #{calendar_id}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise
    end
  end
end
