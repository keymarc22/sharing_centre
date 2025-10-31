class User < ApplicationRecord
  include RolableConcern

  devise :database_authenticatable, :recoverable, :rememberable, :validatable
  validates :name, :email, :country_code, presence: true

  # Google Calendar associations
  has_many :google_calendars, dependent: :destroy
  has_many :taught_sessions, class_name: 'ClassSession', foreign_key: :teacher_id, dependent: :nullify
  has_many :attended_sessions, class_name: 'ClassSession', foreign_key: :student_id, dependent: :nullify
  has_many :owned_sessions, class_name: 'ClassSession', foreign_key: :owner_user_id, dependent: :nullify
end

# class Administrative < User
# end

# class Owner < User
# end