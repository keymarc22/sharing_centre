# frozen_string_literal: true

class Calendar::MainComponent < ApplicationComponent
  attr_reader :calendar_date

  def initialize(calendar_date: Date.today)
    @calendar_date = calendar_date
  end

  def first_day
    day = calendar_date.beginning_of_month.wday
    day = 7 if day == 0 # Convert Sunday from 0 to 7
    day -= 1
  end

  def days_in_month
    calendar_date.end_of_month.day
  end
end
