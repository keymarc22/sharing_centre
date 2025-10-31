class ProcessGooglePushJob < ApplicationJob
  queue_as :default
  
  # Process a Google Calendar push notification
  # @param channel_id [String] The notification channel ID
  # @param resource_uri [String] The resource URI
  # @param resource_state [String] The resource state (sync, exists, not_exists)
  def perform(channel_id:, resource_uri: nil, resource_state: 'sync')
    Rails.logger.info("Processing Google push notification for channel #{channel_id}")
    
    # Find the watch channel
    watch_channel = GoogleWatchChannel.find_by(channel_id: channel_id)
    
    unless watch_channel
      Rails.logger.warn("Watch channel #{channel_id} not found")
      return
    end
    
    # Check if channel is still active
    unless watch_channel.active?
      Rails.logger.warn("Watch channel #{channel_id} has expired")
      return
    end
    
    google_calendar = watch_channel.google_calendar
    
    case resource_state
    when 'sync'
      # Initial sync notification - no action needed
      Rails.logger.info("Received sync notification for channel #{channel_id}")
      
    when 'exists'
      # Calendar has changes - trigger sync
      Rails.logger.info("Received exists notification for channel #{channel_id}, triggering sync")
      SyncUserCalendarJob.perform_later(google_calendar.id)
      
    when 'not_exists'
      # Resource no longer exists - clean up
      Rails.logger.warn("Received not_exists notification for channel #{channel_id}, cleaning up")
      watch_channel.destroy
      google_calendar.clear_watch!
      
    else
      Rails.logger.warn("Unknown resource state: #{resource_state}")
    end
    
  rescue StandardError => e
    Rails.logger.error("Failed to process push notification for channel #{channel_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end
end
