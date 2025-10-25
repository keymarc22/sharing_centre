class Views::Dashboard::Index < Views::Base

  def initialize(classes)
    @classes = classes
  end

  def page_title = "Dashboard"

  def view_template
    Layout(title: "Dashboard") do

      if current_user.student?
        welcome_section

      else
        h1 { "Instructor Dashboard Coming Soon!" }
      end

      classes_section
    end
  end

  private

  def welcome_section
    div(class: "welcome-card") do
      div(class: "welcome-content") do
        div(class: "welcome-text") do
          h2(class: "welcome-title") { "Welcome back, #{current_user.name}!" }
          # p(class: "welcome-message") do

          # end
          # button(class: "buy-button") { "Buy Lesson" }
        end
        div(class: "welcome-image") do
         raw lucide_icon "book-open", class: "book-icon"
        end
      end
    end
  end

  def classes_section
    div(class: 'classes-section') do
      div(class: 'section-header') do
        h3(class: 'section-title') { "Classes" }
        button(class: 'view-all-button') { "View All" }
      end

      div(class: 'classes-grid') do
        # @classes.each do |class_item|
        #   div(class: "class-card blue-card light-blue-card") do
        #     div(class: 'class-card-content') do
        #       h4(class: 'class-title') { class_item.name }
        #       div(class: 'avatar-group') do
        #         class_item[:avatars].each do |avatar|
        #           div(class: "class-avatar") do
        #             span(class: "avatar-text") { avatar }
        #           end
        #         end
        #       end
        #     end
        #   end
        # end
      end
    end
  end
end