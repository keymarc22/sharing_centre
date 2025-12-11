class User < ApplicationRecord
  include RolableConcern

  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :omniauthable, :validatable, omniauth_providers: [:google_oauth2]
  
  validates :name, :email, :country_code, presence: true
  
  def self.from_omniauth(auth)
    auth_info = auth.info
    return nil unless auth_info
    
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.name = auth_info.name || auth_info.email.split('@').first
      user.email = auth_info.email
      user.password = Devise.friendly_token[0, 20]
      user.avatar_url = auth_info.image
      user.country_code = auth_info.country_code || 'MX'
    end
  end
end
