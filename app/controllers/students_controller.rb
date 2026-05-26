class StudentsController < ApplicationController
  def index
    @students = if current_user.admin?
      Student.all.order(:name)
    elsif current_user.teacher?
      Student.joins(:class_sessions)
             .where(class_sessions: { teacher_id: current_user.id })
             .distinct
             .order(:name)
    else
      redirect_to root_path and return
    end
  end

  def new
    @user = User.new(role: Role[:student])
  end
end