class Ui::TableComponent < ApplicationComponent
  attr_reader :caption, :options, :head, :rows, :actions

  # Accepts optional :head (array), :rows (array of arrays or values), :actions (array of symbols)
  def initialize(caption: nil, **options)
    @caption = caption
    @options = options || {}
    @head = @options.delete(:head) || []
    @rows = @options.delete(:rows) || []
    @actions = @options.delete(:actions) || []
  end

  def has_rows?
    @rows && @rows.any?
  end

  def action_links
    return nil unless @actions && @actions.any?

    links = @actions.map do |action|
      case action
      when :edit
        view_context.link_to(lucide_icon("edit-2", class: "inline w-4 h-4 mr-2"), "#", class: tw("text-blue-600 hover:text-blue-800"))
      when :delete
        view_context.link_to(lucide_icon("trash", class: "inline w-4 h-4 mr-2"), "#", class: tw("text-red-600 hover:text-red-800"))
      when :view
        view_context.link_to(lucide_icon("eye", class: "inline w-4 h-4 mr-2"), "#", class: tw("text-green-600 hover:text-green-800"))
      else
        nil
      end
    end.compact

    view_context.safe_join(links, ' ')
  end

end
