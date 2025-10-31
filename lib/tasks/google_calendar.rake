namespace :google_calendar do
  desc 'Bootstrap Google Calendars for all users'
  task bootstrap_calendars: :environment do
    puts "Bootstrapping Google Calendars for all users..."
    
    users = User.all
    users.each do |user|
      begin
        puts "\nProcessing user: #{user.email}"
        
        # Initialize service for the user
        service = GoogleCalendarService.new(
          user: user,
          impersonated_email: user.email
        )
        
        # List user's calendars
        calendar_list = service.list_calendars
        
        calendar_list.items.each do |calendar_item|
          # Create or update GoogleCalendar record
          google_calendar = GoogleCalendar.find_or_initialize_by(
            user: user,
            calendar_id: calendar_item.id
          )
          
          google_calendar.assign_attributes(
            summary: calendar_item.summary,
            time_zone: calendar_item.time_zone,
            metadata: {
              access_role: calendar_item.access_role,
              primary: calendar_item.primary
            }
          )
          
          if google_calendar.save
            puts "  ✓ #{calendar_item.summary} (#{calendar_item.id})"
          else
            puts "  ✗ Failed to save #{calendar_item.summary}: #{google_calendar.errors.full_messages.join(', ')}"
          end
        end
      rescue StandardError => e
        puts "  ✗ Error processing user #{user.email}: #{e.message}"
        puts "    #{e.backtrace.first(3).join("\n    ")}"
      end
    end
    
    puts "\nBootstrap complete!"
    puts "Total calendars: #{GoogleCalendar.count}"
  end
  
  desc 'Setup watch channels for all calendars'
  task setup_watches: :environment do
    puts "Setting up watch channels for all calendars..."
    
    webhook_url = ENV['GOOGLE_CALENDAR_WEBHOOK_URL']
    unless webhook_url
      puts "ERROR: GOOGLE_CALENDAR_WEBHOOK_URL environment variable must be set"
      puts "Example: export GOOGLE_CALENDAR_WEBHOOK_URL='https://your-domain.com/google/calendar/push'"
      exit 1
    end
    puts "Using webhook URL: #{webhook_url}"
    
    GoogleCalendar.all.each do |google_calendar|
      begin
        puts "\nProcessing calendar: #{google_calendar.calendar_id} (User: #{google_calendar.user.email})"
        
        # Skip if already has active watch
        if google_calendar.watch_active?
          puts "  ⏭ Already has active watch (expires: #{google_calendar.watch_expires_at})"
          next
        end
        
        # Initialize service
        service = GoogleCalendarService.new(
          user: google_calendar.user,
          impersonated_email: google_calendar.user.email
        )
        
        # Setup watch
        channel_id = SecureRandom.uuid
        channel = service.watch_calendar(
          calendar_id: google_calendar.calendar_id,
          params: {
            channel_id: channel_id,
            webhook_url: webhook_url,
            expiration: (Time.current + 7.days).to_i * 1000 # milliseconds
          }
        )
        
        # Create watch channel record and update calendar
        expires_at_time = Time.at(channel.expiration / 1000)
        
        GoogleWatchChannel.create!(
          channel_id: channel.id,
          resource_id: channel.resource_id,
          resource_uri: channel.resource_uri,
          google_calendar: google_calendar,
          expires_at: expires_at_time,
          metadata: {
            kind: channel.kind
          }
        )
        
        google_calendar.setup_watch!(
          channel_id: channel.id,
          resource_id: channel.resource_id,
          expires_at: expires_at_time
        )
        
        puts "  ✓ Watch channel created (expires: #{google_calendar.watch_expires_at})"
        
      rescue StandardError => e
        puts "  ✗ Error setting up watch: #{e.message}"
        puts "    #{e.backtrace.first(3).join("\n    ")}"
      end
    end
    
    puts "\nWatch setup complete!"
    puts "Active watches: #{GoogleWatchChannel.active.count}"
  end
  
  desc 'Clean up expired watch channels'
  task cleanup_expired_watches: :environment do
    puts "Cleaning up expired watch channels..."
    
    expired_channels = GoogleWatchChannel.expired
    count = expired_channels.count
    
    expired_channels.find_each do |channel|
      begin
        # Try to stop the watch on Google's side
        service = GoogleCalendarService.new(
          user: channel.google_calendar.user,
          impersonated_email: channel.google_calendar.user.email
        )
        
        service.stop_watch(
          channel_id: channel.channel_id,
          resource_id: channel.resource_id
        )
      rescue StandardError => e
        puts "  Warning: Could not stop watch #{channel.channel_id}: #{e.message}"
      end
      
      # Clean up local records
      channel.google_calendar.clear_watch!
      channel.destroy
      
      puts "  ✓ Cleaned up channel #{channel.channel_id}"
    end
    
    puts "\nCleanup complete! Removed #{count} expired channels."
  end
  
  desc 'Sync all calendars now'
  task sync_all: :environment do
    puts "Enqueuing sync for all calendars..."
    
    force_full_sync = ENV['FORCE_FULL_SYNC'] == 'true'
    throttle_delay = ENV['THROTTLE_DELAY']&.to_i || 2
    
    SyncAllCalendarsJob.perform_later(
      force_full_sync: force_full_sync,
      throttle_delay: throttle_delay
    )
    
    puts "✓ Sync job enqueued"
    puts "  Force full sync: #{force_full_sync}"
    puts "  Throttle delay: #{throttle_delay} seconds"
  end
end
