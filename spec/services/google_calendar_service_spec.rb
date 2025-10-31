require 'rails_helper'

RSpec.describe GoogleCalendarService do
  describe '#initialize' do
    pending 'initializes with user OAuth credentials'
    pending 'initializes with service account impersonation'
    pending 'raises error when neither user nor impersonated_email is provided'
  end

  describe '#list_events' do
    pending 'fetches events from Google Calendar'
    pending 'uses sync_token for incremental sync'
    pending 'handles sync token invalid error'
  end

  describe '#fetch_event' do
    pending 'fetches a specific event by ID'
  end

  describe '#create_event' do
    pending 'creates a new event in Google Calendar'
  end

  describe '#update_event' do
    pending 'updates an existing event in Google Calendar'
  end

  describe '#delete_event' do
    pending 'deletes an event from Google Calendar'
  end

  describe '#watch_calendar' do
    pending 'sets up a watch channel for calendar changes'
  end

  describe '#stop_watch' do
    pending 'stops a watch channel'
  end
end
