class ClassSession < ApplicationRecord
  # Associations
  belongs_to :teacher, class_name: 'User'
  belongs_to :student, class_name: 'User', optional: true
  belongs_to :owner_user, class_name: 'User', optional: true
  belongs_to :owner_calendar, class_name: 'GoogleCalendar', optional: true
  belongs_to :parent_session, class_name: 'ClassSession', optional: true
  has_many :child_sessions, class_name: 'ClassSession', foreign_key: :parent_session_id, dependent: :nullify

  # Validations
  validates :title, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :end_after_start

  # Enums
  enum status: {
    scheduled: 0,
    completed: 1,
    cancelled: 2,
    rescheduled: 3
  }

  # Scopes
  scope :upcoming, -> { where('start_at > ?', Time.current).order(start_at: :asc) }
  scope :past, -> { where('start_at <= ?', Time.current).order(start_at: :desc) }
  scope :for_teacher, ->(teacher_id) { where(teacher_id: teacher_id) }
  scope :for_student, ->(student_id) { where(student_id: student_id) }
  scope :with_google_event, -> { where.not(google_event_id: nil) }

  # Returns the effective owner of the calendar for this session
  # Falls back to teacher if owner_user_id is not set
  def effective_owner
    owner_user || teacher
  end

  # Returns the effective calendar id for this session
  def effective_owner_calendar_id
    owner_calendar&.calendar_id || 'primary'
  end

  # Sync from a Google Calendar event hash
  # @param g_event_hash [Hash] The Google Calendar event data
  # @param owner_user [User] The user who owns the calendar
  # @param owner_calendar_id [String] The calendar ID
  # @return [ClassSession] The created or updated ClassSession
  def self.sync_from_google_event(g_event_hash, owner_user:, owner_calendar_id:)
    event_id = g_event_hash['id']
    return nil unless event_id

    # Find existing session or initialize new one
    session = find_or_initialize_by(google_event_id: event_id)
    
    # Handle recurring event instances
    if g_event_hash['recurringEventId'].present?
      session.recurring_event_id = g_event_hash['recurringEventId']
      session.original_start_time = parse_google_datetime(g_event_hash.dig('originalStartTime', 'dateTime'))
      
      # Try to find parent session
      parent = find_by(google_event_id: g_event_hash['recurringEventId'])
      session.parent_session = parent if parent
    end

    # Parse start and end times
    start_time = parse_google_datetime(g_event_hash.dig('start', 'dateTime') || g_event_hash.dig('start', 'date'))
    end_time = parse_google_datetime(g_event_hash.dig('end', 'dateTime') || g_event_hash.dig('end', 'date'))

    # Update session attributes
    session.assign_attributes(
      title: g_event_hash['summary'] || 'Untitled Event',
      description: g_event_hash['description'],
      start_at: start_time,
      end_at: end_time,
      time_zone: g_event_hash.dig('start', 'timeZone') || owner_user.time_zone || 'UTC',
      location: g_event_hash['location'],
      google_event_raw: g_event_hash,
      google_event_etag: g_event_hash['etag'],
      google_event_updated_at: parse_google_datetime(g_event_hash['updated']),
      google_calendar_timezone: g_event_hash.dig('start', 'timeZone'),
      last_synced_at: Time.current,
      owner_user: owner_user,
      owner_calendar_id: GoogleCalendar.find_by(user: owner_user, calendar_id: owner_calendar_id)&.id
    )

    # Set teacher if not already set
    # Check if user has teacher role using the RolableConcern method
    if owner_user.teacher?
      session.teacher ||= owner_user
    else
      session.teacher ||= owner_user # Fallback for any user
    end

    # Parse recurrence rules
    if g_event_hash['recurrence'].present?
      session.recurrence_rule = g_event_hash['recurrence'].join("\n")
    end

    # Handle status
    if g_event_hash['status'] == 'cancelled'
      session.status = :cancelled
    elsif session.start_at && session.start_at < Time.current
      session.status ||= :completed
    else
      session.status ||= :scheduled
    end

    session.save!
    session
  rescue StandardError => e
    Rails.logger.error("Failed to sync event #{event_id}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end

  private

  def end_after_start
    return unless start_at && end_at
    
    if end_at <= start_at
      errors.add(:end_at, 'must be after start time')
    end
  end

  # Parse Google Calendar datetime string
  def self.parse_google_datetime(datetime_str)
    return nil unless datetime_str
    
    # Handle date-only strings (all-day events)
    if datetime_str.is_a?(String) && datetime_str.match?(/^\d{4}-\d{2}-\d{2}$/)
      Date.parse(datetime_str).to_time
    else
      Time.parse(datetime_str.to_s)
    end
  rescue ArgumentError, TypeError
    nil
  end
end
