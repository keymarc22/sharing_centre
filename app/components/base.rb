# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Rails.application.routes.url_helpers

  # register_value_helper :lucide_icon

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end

  delegate :current_user, :lucide_icon, to: :view_context

end
