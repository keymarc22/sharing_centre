class GoogleCalendar < ApplicationRecord
  belongs_to :user
  has_many :class_sessions, foreign_key: :owner_calendar_id, dependent: :nullify
  has_many :google_watch_channels, dependent: :destroy

  validates :calendar_id, presence: true
  validates :calendar_id, uniqueness: { scope: :user_id }

  scope :watched, -> { where.not(watch_channel_id: nil) }
  scope :needs_sync, -> { where('last_synced_at IS NULL OR last_synced_at < ?', 1.hour.ago) }
  scope :watch_expiring_soon, -> { where('watch_expires_at IS NOT NULL AND watch_expires_at < ?', 1.day.from_now) }

  # Check if watch channel is active and not expired
  def watch_active?
    watch_channel_id.present? && watch_expires_at.present? && watch_expires_at > Time.current
  end

  # Update sync token after successful sync
  def update_sync_token!(token)
    update!(sync_token: token, last_synced_at: Time.current)
  end

  # Clear sync token to force full sync next time
  def clear_sync_token!
    update!(sync_token: nil)
  end

  # Setup watch channel
  def setup_watch!(channel_id:, resource_id:, expires_at:)
    update!(
      watch_channel_id: channel_id,
      watch_expires_at: expires_at
    )
  end

  # Clear watch channel
  def clear_watch!
    update!(
      watch_channel_id: nil,
      watch_expires_at: nil
    )
  end
end
