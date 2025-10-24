class User < ApplicationRecord
  include RolableConcern

  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  validates :name, :email, :country_code, presence: true
end

# class Administrative < User
# end

# class Owner < User
# end