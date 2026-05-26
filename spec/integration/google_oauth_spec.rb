require 'rails_helper'
require 'ostruct'

RSpec.describe 'Google OAuth Flow', type: :integration do
  describe 'User Login with Google' do
    let(:auth_double) do
      double('OmniAuth::AuthHash',
        provider: 'google_oauth2',
        uid: '123456',
        info: double(
          name: 'Test User',
          email: 'test.user@example.com',
          image: 'https://example.com/avatar.jpg',
          country_code: nil
        ),
        credentials: double(
          token: 'access_token_abc123',
          refresh_token: 'refresh_token_xyz789',
          expires_at: (Time.current + 1.hour).to_i,
          present?: true
        )
      )
    end

    it 'creates a new user and saves Google tokens' do
      user = User.from_omniauth(auth_double)

      expect(user).to be_persisted
      expect(user.email).to eq('test.user@example.com')
      expect(user.google_access_token).to eq('access_token_abc123')
      expect(user.google_refresh_token).to eq('refresh_token_xyz789')
      expect(user.provider).to eq('google_oauth2')
      expect(user.uid).to eq('123456')
    end

    it 'updates tokens on re-login' do
      user = User.from_omniauth(auth_double)
      original_id = user.id

      # Simulate re-login with updated tokens
      new_auth_double = double('OmniAuth::AuthHash',
        provider: 'google_oauth2',
        uid: '123456',
        info: double(
          name: 'Test User',
          email: 'test.user@example.com',
          image: 'https://example.com/avatar.jpg',
          country_code: nil
        ),
        credentials: double(
          token: 'new_access_token',
          refresh_token: 'new_refresh_token',
          expires_at: (Time.current + 1.hour).to_i,
          present?: true
        )
      )

      updated_user = User.from_omniauth(new_auth_double)

      expect(updated_user.id).to eq(original_id)
      expect(updated_user.google_access_token).to eq('new_access_token')
      expect(updated_user.google_refresh_token).to eq('new_refresh_token')
    end

    it 'marks user as google_connected' do
      user = User.from_omniauth(auth_double)

      expect(user.google_connected?).to be true
    end
  end

  describe 'Detecting Expired Tokens' do
    it 'detects when token is expired' do
      user = create(:user, :with_google_oauth, google_token_expires_at: 1.hour.ago)

      expect(user.google_token_expired?).to be true
    end

    it 'detects when token is still valid' do
      user = create(:user, :with_google_oauth, google_token_expires_at: 1.hour.from_now)

      expect(user.google_token_expired?).to be false
    end

    it 'handles missing expiration time' do
      user = create(:user, google_token_expires_at: nil)

      expect(user.google_token_expired?).to be false
    end
  end

  describe 'Calendar Access Control' do
    let(:user_with_google) { create(:user, :with_google_oauth, role: 'teacher') }
    let(:user_without_google) { create(:user, role: 'teacher') }

    it 'allows teacher with Google connection to create classes' do
      expect(user_with_google.google_connected?).to be true

      class_session = ClassSession.new(
        title: 'Spanish Class',
        teacher_id: user_with_google.id,
        student_id: create(:user, role: 'student').id,
        start_at: 1.hour.from_now,
        end_at: 2.hours.from_now
      )

      expect(class_session).to be_valid
    end

    it 'teacher without Google can create classes but they won\'t sync' do
      expect(user_without_google.google_connected?).to be false

      class_session = ClassSession.new(
        title: 'French Class',
        teacher_id: user_without_google.id,
        student_id: create(:user, role: 'student').id,
        start_at: 1.hour.from_now,
        end_at: 2.hours.from_now
      )

      expect(class_session).to be_valid
      expect(class_session.google_event_id).to be_nil
    end
  end

  describe 'Token Refresh Flow' do
    it 'automatically refreshes expired token when making API call' do
      user = create(:user, :with_google_oauth, google_token_expires_at: 1.hour.ago)

      # Mock the refresh
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:expired?).and_return(true)
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:refresh!)
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:access_token).and_return('refreshed_token')
      allow_any_instance_of(Google::Auth::UserRefreshCredentials).to receive(:expires_at).and_return((Time.current + 1.hour).to_i)

      # When making a call to GoogleCalendarService, the token should be refreshed
      allow_any_instance_of(Google::Apis::CalendarV3::CalendarService).to receive(:list_events).and_return(double('Result', items: []))

      service = GoogleCalendarService.new(user)
      service.list_events(time_min: 1.day.ago, time_max: 1.day.from_now)

      user.reload
      expect(user.google_access_token).to eq('refreshed_token')
    end
  end
end
