require 'rails_helper'

RSpec.describe GoogleCalendarService, type: :service do
  let(:user) { create(:user, :teacher, google_access_token: 'token123', google_refresh_token: 'refresh123', google_token_expires_at: 1.hour.from_now) }
  let(:service) { GoogleCalendarService.new(user) }

  describe '#create_event' do
    let(:event_params) do
      {
        summary: 'Test Class',
        description: 'Test Description',
        start: { date_time: 1.hour.from_now.iso8601, time_zone: 'UTC' },
        end: { date_time: 2.hours.from_now.iso8601, time_zone: 'UTC' },
        attendees: [{ email: 'student@example.com' }]
      }
    end

    it 'creates an event in Google Calendar' do
      mock_event = double('Google::Apis::CalendarV3::Event', id: 'event123', hangout_link: 'https://meet.google.com/abc')

      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:insert_event).and_return(mock_event)

      result = service.create_event(event_params)

      expect(result.id).to eq('event123')
      expect(result.hangout_link).to eq('https://meet.google.com/abc')
    end

    it 'raises error when Google API fails' do
      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:insert_event).and_raise(Google::Apis::Error.new('API Error'))

      expect { service.create_event(event_params) }.to raise_error(Google::Apis::Error)
    end
  end

  describe '#update_event' do
    let(:google_event_id) { 'event123' }
    let(:event_params) do
      {
        summary: 'Updated Class',
        start: { date_time: 2.hours.from_now.iso8601, time_zone: 'UTC' },
        end: { date_time: 3.hours.from_now.iso8601, time_zone: 'UTC' }
      }
    end

    it 'updates an event in Google Calendar' do
      mock_event = double('Google::Apis::CalendarV3::Event', id: google_event_id)

      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:update_event).and_return(mock_event)

      result = service.update_event(google_event_id, event_params)

      expect(result.id).to eq(google_event_id)
    end
  end

  describe '#delete_event' do
    let(:google_event_id) { 'event123' }

    it 'deletes an event from Google Calendar' do
      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:delete_event)

      expect { service.delete_event(google_event_id) }.not_to raise_error
    end
  end

  describe '#list_events' do
    let(:time_min) { 1.day.ago }
    let(:time_max) { 1.day.from_now }

    it 'lists events from Google Calendar' do
      mock_events = [
        double('Event', id: 'event1', summary: 'Class 1', start: double(date_time: 1.hour.from_now)),
        double('Event', id: 'event2', summary: 'Class 2', start: double(date_time: 2.hours.from_now))
      ]
      mock_result = double('Result', items: mock_events)

      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(mock_result)

      result = service.list_events(time_min: time_min, time_max: time_max)

      expect(result.count).to eq(2)
      expect(result.first.id).to eq('event1')
    end

    it 'returns empty array when no events' do
      mock_result = double('Result', items: nil)

      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(mock_result)

      result = service.list_events(time_min: time_min, time_max: time_max)

      expect(result).to eq([])
    end
  end

  describe 'token refresh' do
    it 'refreshes expired token' do
      expired_user = create(:user, :teacher, google_access_token: 'old_token', google_refresh_token: 'refresh123', google_token_expires_at: 1.hour.ago)
      expired_service = GoogleCalendarService.new(expired_user)

      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:expired?).and_return(true)
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:refresh!)
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:access_token).and_return('new_token')
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:expires_at).and_return(Time.current.to_i + 3600)

      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(double('Result', items: []))

      expired_service.list_events(time_min: 1.day.ago, time_max: 1.day.from_now)

      expired_user.reload
      expect(expired_user.google_access_token).to eq('new_token')
    end
  end
end
