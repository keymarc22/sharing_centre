class GoogleWatchChannel < ApplicationRecord
  belongs_to :google_calendar

  validates :channel_id, presence: true, uniqueness: true
  validates :resource_id, presence: true
  validates :resource_uri, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :expiring_soon, -> { where('expires_at > ? AND expires_at < ?', Time.current, 1.day.from_now) }

  # Check if channel is still active
  def active?
    expires_at > Time.current
  end

  # Check if channel is expiring soon
  def expiring_soon?
    expires_at > Time.current && expires_at < 1.day.from_now
  end
end
