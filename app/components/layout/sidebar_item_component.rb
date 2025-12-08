class Layout::SidebarItemComponent < ApplicationComponent
  attr_reader :item

  def initialize(item:)
    @item = item
  end

  def render?
    current_user.can?(@item[:ability], :read)
  end

  def active?
    current_path = view_context.request.path
    item_path = item[:path]

    current_path == item_path # || (item[:active_paths]&.any? { |path| current_path.start_with?(path) })
  end
end