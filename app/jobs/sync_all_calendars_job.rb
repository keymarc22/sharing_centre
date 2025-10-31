class SyncAllCalendarsJob < ApplicationJob
  queue_as :default
  
  # Sync all Google calendars with throttling
  # @param force_full_sync [Boolean] Force a full sync for all calendars
  # @param throttle_delay [Integer] Delay in seconds between each sync job (default: 2)
  def perform(force_full_sync: false, throttle_delay: 2)
    Rails.logger.info("Starting sync for all calendars (force_full_sync: #{force_full_sync})")
    
    calendars = GoogleCalendar.all
    total_count = calendars.count
    
    Rails.logger.info("Found #{total_count} calendars to sync")
    
    calendars.each_with_index do |google_calendar, index|
      begin
        # Enqueue sync job with delay to avoid rate limits
        delay = index * throttle_delay
        SyncUserCalendarJob.set(wait: delay.seconds).perform_later(
          google_calendar.id,
          force_full_sync: force_full_sync
        )
        
        Rails.logger.debug("Enqueued sync for calendar #{google_calendar.id} (#{index + 1}/#{total_count}) with #{delay}s delay")
      rescue StandardError => e
        Rails.logger.error("Failed to enqueue sync for calendar #{google_calendar.id}: #{e.message}")
      end
    end
    
    Rails.logger.info("Completed enqueuing sync jobs for #{total_count} calendars")
  end
end
