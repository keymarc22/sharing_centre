class Components::Layout < Components::Base
  def initialize(title:, show_sidebar: true)
    @title = title
    @show_sidebar = show_sidebar
  end

  def view_template
    main(class: "mx-auto mt-28 px-5") do
      div(class: "dashboard-container") do
        render Components::Sidebar.new

        div(class: "main-content") do
          yield
        end

        if @show_sidebar
          render Components::RightSidebar.new
        end
      end
    end
  end
end
