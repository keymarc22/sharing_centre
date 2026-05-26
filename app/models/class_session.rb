class ClassSession < ApplicationRecord
  belongs_to :teacher, class_name: 'User'
  belongs_to :student, class_name: 'User'
  belongs_to :lesson, optional: true

  validates :title, :start_at, :end_at, :teacher, :student, presence: true
  validate :end_time_after_start_time

  def recurring?
    recurrence_rule.present?
  end

  def occurrences_between(range_start, range_end)
    return [start_at] unless recurring?

    schedule = IceCube::Schedule.new(start_at)
    schedule.add_recurrence_rule(IceCube::Rule.from_ical(recurrence_rule))
    schedule.occurrences_between(range_start.to_time, range_end.to_time)
  end

  def update_recurrence_ends_at!
    return unless recurring?

    schedule = IceCube::Schedule.new(start_at)
    schedule.add_recurrence_rule(IceCube::Rule.from_ical(recurrence_rule))
    last_occurrence = schedule.all_occurrences.last
    update_column(:recurrence_ends_at, last_occurrence&.to_date)
  rescue StandardError
    nil
  end

  private

  def end_time_after_start_time
    return if end_at.blank? || start_at.blank?
    errors.add(:end_at, 'must be after start_at') if end_at <= start_at
  end
end
