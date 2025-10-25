class Components::Sidebar < Components::Base

  def view_template
    div( class: 'sidebar') do
      div(class: 'sidebar-content') do
        logo_container

        nav(class: "sidebar-nav") do
          resolved_items.each { |item| nav_item(item) }
        end

        div(class: 'sidebar-footer') do
          ul do
            li do
              a(href: '', class: 'nav-item', rel: "noopener") do
                raw view_context.lucide_icon("log-out")
                span { 'Cerrar sesión' }
              end
            end
          end
        end
      end
    end
  end

  def resolved_items
    NAV_ITEMS
      .select { |raw| current_user.can?(raw[:ability], :read) }
      .map { |raw| resolve_raw(raw) }
  end

  private

  NAV_ITEMS = [
    { label: ->(c) { c.t('views.sidebar.home') }, icon: "house", path: ->(c) { c.root_path }, ability: :dashboard },
    { label: ->(c) { c.t('views.sidebar.students')  }, icon: "users", path: ->(c) { c.students_path rescue "#" }, ability: :students },
    { label: ->(c) { c.t('views.sidebar.teachers')  }, icon: "graduation-cap", path: ->(c) { c.teachers_path rescue "#" }, ability: :teachers },
    { label: ->(c) { c.t('views.sidebar.programs')   }, icon: "award", path: ->(c) { c.programs_path rescue "#" }, ability: :programs },
    { label: ->(c) { c.t('views.sidebar.lessons')    }, icon: "book-open-check", path: ->(c) { c.lessons_path rescue "#" }, ability: :lessons },
    { label: ->(c) { c.t('views.sidebar.books')      }, icon: "book", path: ->(c) { c.books_path rescue "#" }, ability: :books },
    { label: ->(c) { c.t('views.sidebar.classes')    }, icon: "calendar", path: ->(c) { c.classes_path rescue "#" }, ability: :classes }
  ].freeze

  def resolve_raw(raw)
    {
      label: raw[:label].respond_to?(:call) ? raw[:label].call(view_context) : raw[:label],
      icon:  raw[:icon],
      path:  raw[:path].respond_to?(:call)  ? raw[:path].call(view_context)  : raw[:path],
      ability: raw[:ability]
    }
  end

  def nav_item(item)
    classes = ["nav-item"]
    classes << "active" if active_nav_item?(item)

    a(href: item[:path], class: classes.join(" ")) do
      if item[:icon]
        raw view_context.lucide_icon(item[:icon])
      end
      span(class: "nav-label") { item[:label] }
    end
  end

  def active_nav_item?(item)
    current_path = view_context.request.path
    item_path = item[:path]

    current_path == item_path # || (item[:active_paths]&.any? { |path| current_path.start_with?(path) })
  end

  def logo_container
    div(class: 'logo-container') do
      div(class: 'logo-icon') do
        raw view_context.image_tag('isotipo.png', alt: 'Sharing Centre Logo', class: 'logo-image')
        span(class: 'logo-text') { 'Sharing Centre' }
      end
    end
  end
end