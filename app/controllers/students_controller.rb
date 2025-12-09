class StudentsController < ApplicationController
  def index

  end

  def new
    @user = User.new(role: Role[:student])
  end
end