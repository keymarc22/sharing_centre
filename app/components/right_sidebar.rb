class Components::RightSidebar < Components::Base
  def view_template
    div(class: 'right-sidebar') do
      div(class: 'profile-section') do
        div(class: 'profile-avatar') do
          current_user.name[0].upcase
        end

        h3(class: 'profile-name') do
          current_user.name
        end

        button(class: 'profile-button') do
          'Profile'
        end
      end

      render Components::Calendar.new
    end
  end
end