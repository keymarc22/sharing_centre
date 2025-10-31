require 'rails_helper'

RSpec.describe Admin::GoogleCalendarsController, type: :controller do
  describe 'GET #index' do
    pending 'lists all Google calendars for admins'
    pending 'denies access to non-admin users'
  end

  describe 'POST #sync_now' do
    pending 'enqueues sync job for specific calendar'
    pending 'denies access to non-admin users'
  end

  describe 'POST #sync_all' do
    pending 'enqueues sync job for all calendars'
    pending 'denies access to non-admin users'
  end

  describe 'POST #fetch_event' do
    pending 'fetches and syncs a specific event'
    pending 'returns error when event_id is missing'
    pending 'denies access to non-admin users'
  end
end
