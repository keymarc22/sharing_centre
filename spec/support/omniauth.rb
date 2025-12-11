require 'omniauth'

module OmniAuthHelpers
  def mock_google_oauth(uid: '12345', email: 'test-oauteeeh@example.com', name: 'Test User', provider: 'google_oauth2')
    OmniAuth::AuthHash.new(
      provider:,
      uid:,
      info: { email:, name: },
      credentials: {
        token: 'mock_token',
        expires_at: Time.now.to_i + 1_000_000
      }
    )
  end
end

RSpec.configure do |config|
  config.include OmniAuthHelpers

  config.before(:each) do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

  config.after(:each) do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end