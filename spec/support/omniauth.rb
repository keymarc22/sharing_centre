# frozen_string_literal: true

# Configuración de OmniAuth para tests
OmniAuth.config.test_mode = true

module OmniauthHelpers
  # Helper method para crear un mock de autenticación de Google
  # Parámetros:
  #   uid: ID único del usuario en Google
  #   email: Email del usuario
  #   name: Nombre completo del usuario
  #   provider: Proveedor OAuth (por defecto 'google_oauth2')
  def mock_google_oauth(uid: '123456789', email: 'test@example.com', name: 'Test User', provider: 'google_oauth2')
    name_parts = name&.split || []
    OmniAuth::AuthHash.new({
      provider: provider,
      uid: uid,
      info: {
        email: email,
        name: name,
        first_name: name_parts.first,
        last_name: name_parts.last,
        image: 'https://lh3.googleusercontent.com/a/default-user'
      },
      credentials: {
        token: 'mock_token',
        refresh_token: 'mock_refresh_token',
        expires_at: Time.now.to_i + 3600,
        expires: true
      },
      extra: {
        raw_info: {
          sub: uid,
          email: email,
          email_verified: true,
          name: name
        }
      }
    })
  end
end

RSpec.configure do |config|
  config.include OmniauthHelpers

  # Limpiar los mocks de OmniAuth después de cada test
  config.after(:each) do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end
