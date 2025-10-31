class GooglePushController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_google_notification
  
  # POST /google/calendar/push
  def receive
    channel_id = request.headers['X-Goog-Channel-ID']
    resource_state = request.headers['X-Goog-Resource-State']
    resource_uri = request.headers['X-Goog-Resource-URI']
    
    Rails.logger.info("Received Google push notification: channel=#{channel_id}, state=#{resource_state}")
    
    # Enqueue job to process the notification
    ProcessGooglePushJob.perform_later(
      channel_id: channel_id,
      resource_uri: resource_uri,
      resource_state: resource_state
    )
    
    # Google expects a 200 OK response
    head :ok
  rescue StandardError => e
    Rails.logger.error("Failed to process push notification: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    
    # Still return 200 to prevent Google from retrying
    head :ok
  end
  
  private
  
  def verify_google_notification
    channel_id = request.headers['X-Goog-Channel-ID']
    
    unless channel_id.present?
      Rails.logger.warn("Received push notification without channel ID")
      head :bad_request
      return false
    end
    
    true
  end
end
