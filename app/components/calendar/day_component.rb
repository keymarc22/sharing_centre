# frozen_string_literal: true

class Calendar::DayComponent < ApplicationComponent

  attr_reader :day, :calendar_date

  def initialize(day:, calendar_date:)
    @day = day
    @calendar_date = calendar_date
  end

  def is_today?
    day == 7
  end

  def resolve_klass
    base_klass = "calendar-day"
    base_klass += " today" if is_today?
    base_klass += " selected" if is_selected? && !is_today?
    base_klass
  end

  def is_selected?
    [19, 29].include?(day)
  end
end
