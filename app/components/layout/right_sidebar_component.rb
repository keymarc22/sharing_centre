class Layout::RightSidebarComponent < ApplicationComponent
  def fetch_calendar_events
    return [] unless current_user.present?

    time_range = Date.today.beginning_of_month..Date.today.end_of_month.end_of_day

    if current_user.admin?
      ClassSession.where(start_at: time_range).order(:start_at)
    elsif current_user.teacher?
      ClassSession.where(teacher_id: current_user.id, start_at: time_range).order(:start_at)
    elsif current_user.student?
      ClassSession.where(student_id: current_user.id, start_at: time_range).order(:start_at)
    else
      []
    end
  end
end