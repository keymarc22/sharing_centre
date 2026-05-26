class User < ApplicationRecord
  include RolableConcern

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, :validatable, omniauth_providers: [:google_oauth2]

  validates :name, :email, :country_code, presence: true

  def self.from_omniauth(auth)
    auth_info = auth.info
    return nil unless auth_info&.email

    user = where(provider: auth.provider, uid: auth.uid).first_or_create do |new_user|
      new_user.name = auth_info.name || auth_info.email.split('@').first
      new_user.email = auth_info.email
      new_user.password = Devise.friendly_token[0, 20]
      new_user.avatar_url = auth_info.image
      new_user.country_code = auth_info.country_code || 'MX'
    end

    # Always update tokens on login
    user.update(
      google_access_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token,
      google_token_expires_at: Time.at(auth.credentials.expires_at)
    ) if auth.credentials.present?

    user
  end

  def google_connected?
    provider == 'google_oauth2' && google_access_token.present?
  end

  def google_token_expired?
    google_token_expires_at.present? && google_token_expires_at < Time.current
  end
end
