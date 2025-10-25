class Views::Dashboard::Index < Views::Base

  def page_title = "Dashboard"

  def view_template
    Layout(title: "Dashboard") do
      h1 { "Dashboard" }

    end
  end
end