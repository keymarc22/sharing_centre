class Views::Base < Phlex::HTML
  include Components

  def around_template
    doctype

    html do
      head do
        title { page_title }
        meta(charset: "utf-8")
        meta(name: "viewport", content: "width=device-width, initial-scale=1")
        meta(name: "description", content: "Learn personalized english online")
        raw csrf_meta_tags
        raw csp_meta_tag

        link rel: "icon", href: '/icon.png', type: 'image/png'
        link rel: 'icon', href: '/icon.svg', type: 'image/svg+xml'
        link rel: "apple-touch-icon", href: '/icon.png'

        raw stylesheet_link_tag :app
        raw javascript_importmap_tags
      end

      body { super }
    end
  end

  private

  delegate :current_user, :stylesheet_link_tag, :javascript_importmap_tags, :csrf_meta_tags, :csp_meta_tag, :lucide_icon, to: :view_context
end