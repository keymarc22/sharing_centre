class ClassSessionsController < ApplicationController
  def index
    base = ClassSession.includes(:teacher, :student)

    @sessions = if current_user.admin?
      base
    elsif current_user.teacher?
      base.where(teacher_id: current_user.id)
    elsif current_user.student?
      base.where(student_id: current_user.id)
    else
      redirect_to root_path and return
    end

    @filter = params[:filter] == 'past' ? 'past' : 'upcoming'
    if @filter == 'upcoming'
      @sessions = @sessions.where('start_at >= ?', Time.current).order(start_at: :asc)
    else
      @sessions = @sessions.where('start_at < ?', Time.current).order(start_at: :desc)
    end
  end
end
