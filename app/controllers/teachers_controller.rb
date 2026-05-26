class TeachersController < ApplicationController
  before_action :require_admin!

  def index
    @teachers = Teacher.all.order(:name)
  end

  private

  def require_admin!
    redirect_to root_path unless current_user.admin?
  end
end