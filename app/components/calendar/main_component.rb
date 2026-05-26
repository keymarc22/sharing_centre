# frozen_string_literal: true

class Calendar::MainComponent < ApplicationComponent
  attr_reader :calendar_date, :events_by_day

  def initialize(calendar_date: Date.today, events: [])
    @calendar_date = calendar_date
    @events_by_day = group_events_by_day(events)
  end

  def first_day
    day = calendar_date.beginning_of_month.wday
    day = 7 if day == 0 # Convert Sunday from 0 to 7
    day -= 1
  end

  def days_in_month
    calendar_date.end_of_month.day
  end

  def prev_month_date
    (calendar_date.beginning_of_month - 1.day).beginning_of_month
  end

  def next_month_date
    calendar_date.end_of_month + 1.day
  end

  private

  def group_events_by_day(events)
    range_start = calendar_date.beginning_of_month.to_time
    range_end = calendar_date.end_of_month.end_of_day.to_time

    expanded = events.flat_map do |event|
      if event.respond_to?(:recurring?) && event.recurring?
        duration = event.end_at - event.start_at
        event.occurrences_between(range_start, range_end).map do |occurrence|
          CalendarOccurrence.new(event, occurrence, occurrence + duration)
        end
      else
        [event]
      end
    end

    expanded.group_by { |e| e.start_at.to_date.day }
  end

  CalendarOccurrence = Struct.new(:source, :start_at, :end_at) do
    def method_missing(name, *args, &block)
      source.respond_to?(name) ? source.send(name, *args, &block) : super
    end

    def respond_to_missing?(name, include_private = false)
      source.respond_to?(name, include_private) || super
    end
  end
end
