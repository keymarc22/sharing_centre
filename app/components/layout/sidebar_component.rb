class Layout::SidebarComponent < ApplicationComponent

  NAV_ITEMS = [
    { label: ->(h) { h.t('.sidebar.home') }, icon: "house", path: ->(h) { h.root_path }, ability: :dashboard },
    { label: ->(h) { h.t('.sidebar.students')  }, icon: "users", path: ->(h) { h.students_path }, ability: :students },
    { label: ->(h) { h.t('.sidebar.teachers')  }, icon: "graduation-cap", path: ->(h) { h.teachers_path }, ability: :teachers },
    { label: ->(h) { h.t('.sidebar.programs')   }, icon: "award", path: ->(h) { (h.respond_to?(:programs_path) && h.programs_path) rescue "#" }, ability: :programs },
    { label: ->(h) { h.t('.sidebar.lessons')    }, icon: "book-open-check", path: ->(h) { (h.respond_to?(:lessons_path) && h.lessons_path) rescue "#" }, ability: :lessons },
    { label: ->(h) { h.t('.sidebar.books')      }, icon: "book", path: ->(h) { (h.respond_to?(:books_path) && h.books_path) rescue "#" }, ability: :books },
    { label: ->(h) { h.t('.sidebar.classes')    }, icon: "calendar", path: ->(h) { (h.respond_to?(:classes_path) && h.classes_path) rescue "#" }, ability: :classes }
  ].freeze

  def initialize
    # Defer resolution until render time so `helpers` and route/url helpers
    # are available. Store the raw NAV_ITEMS and resolve in #items.
    @raw_nav = NAV_ITEMS
  end

  def items
    @raw_nav.map { |item| resolve_raw(item) }
  end

  private

  def resolve_raw(raw)
    # Use `helpers` (available in component render context) rather than view_context
    # to evaluate label/path lambdas so route and translation helpers work.
    label = raw[:label].respond_to?(:call) ? raw[:label].call(helpers) : raw[:label]
    path  = raw[:path].respond_to?(:call)  ? raw[:path].call(helpers)  : raw[:path]

    {
      label: label,
      icon:  raw[:icon],
      path:  path,
      ability: raw[:ability]
    }
  end

  def logo_container
    # If used from Ruby rendering (Phlex), use helpers.image_tag to render image
    # otherwise the ERB template can call image_tag directly.
    helpers.image_tag('isotipo.png', alt: 'Sharing Centre Logo', class: 'logo-image')
  end
end