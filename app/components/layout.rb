class Components::Layout < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template
    main(class: "mx-auto mt-28 px-5") do
      div(class: "dashboard-container") do
        render Components::Sidebar.new

        div(class: "main-content") do
          yield
        end
      end
    end
  end
end