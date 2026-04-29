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
    events.group_by { |event| event.start_at.day }
  end
end
