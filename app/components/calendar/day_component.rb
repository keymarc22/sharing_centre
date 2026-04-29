# frozen_string_literal: true

class Calendar::DayComponent < ApplicationComponent

  attr_reader :day, :calendar_date

  def initialize(day:, calendar_date:, events: [])
    @day = day
    @calendar_date = calendar_date
    @events = events
  end

  def is_today?
    Date.new(calendar_date.year, calendar_date.month, day) == Date.today
  end

  def has_events?
    @events.any?
  end

  def resolve_klass
    base_klass = "calendar-day"
    base_klass += " today" if is_today?
    base_klass += " has-events" if has_events?
    base_klass
  end

  def serialized_events
    @events.map do |event|
      {
        id: event.id,
        title: event.title,
        start: event.start_at.iso8601,
        end: event.end_at.iso8601,
        extendedProps: {
          meet_link: event.meet_link,
          teacher_name: event.teacher&.name,
          student_name: event.student&.name,
          description: event.description
        }
      }
    end.to_json
  end
end
