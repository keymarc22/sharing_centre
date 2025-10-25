class DashboardController < ApplicationController
  def index
    render Views::Dashboard::Index.new(
      classes: [], # from google calendar?
      lessons: [],
      books: [],
    )
  end

  private

  
end
