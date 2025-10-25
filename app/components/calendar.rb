class Components::Calendar < Components::Base
  def view_template
    calendar_date = Date.today

    div(class: 'calendar-section', data: { controller: 'calendar', 'calendar-date-value': ''}) do
      div(class: 'calendar-header') do
        h4(class: 'calendar-title') do
          calendar_date.strftime("%B %d, %Y")
        end

        div(class: 'calendar-nav') do
          button(class: 'calendar-nav-button', data: { action: 'calendar#prevMonth' }) do
            raw lucide_icon("chevron-left")
          end
          button(class: 'calendar-nav-button', data: { action: 'calendar#nextMonth' }) do
            raw lucide_icon("chevron-right")
          end
        end
      end

      div(class: 'calendar-weekdays') do
        %w[Mon Tue Wed Thu Fri Sat Sun].each do |day|
          div(class: 'weekday') { day }
        end
      end

      days_in_month = calendar_date.end_of_month.day
      first_day = calendar_date.beginning_of_month.wday
      first_day = 7 if first_day == 0 # Convert Sunday from 0 to 7
      first_day -= 1 # Adjust for Monday start

      div(class: 'calendar-days', data: { 'calendar-target': 'days' }) do
        first_day.times do |i|
          prev_date = calendar_date.beginning_of_month - (first_day - i).days
          div(class: "calendar-day prev-month") do
            prev_date.day
          end
        end

        (1..days_in_month).each do |day|
          is_today = day == 7 # Highlighting day 7 as shown in the image
          is_selected = [19, 29].include?(day) # Selected days as shown
          css_classes = "calendar-day"
          css_classes += " today" if is_today
          css_classes += " selected" if is_selected && !is_today

          div(class: css_classes, data: { action: "click->calendar#selectDay", day: day }) do
            day
          end
        end
      end
    end
  end
end