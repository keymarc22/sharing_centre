class CalendarComponent < ApplicationComponent
  attr_reader :calendar_date

  def initialize(calendar_date: Date.today)
    @calendar_date = calendar_date
  end
end