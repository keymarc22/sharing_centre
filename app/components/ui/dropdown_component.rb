class Ui::DropdownComponent < ApplicationComponent
  attr_reader :inner_block, :options, :trigger

  erb_template <<-ERB
    <%= render Components::Ui::Popover.new(
      trigger:,
      content:,
    ) %>
  ERB

  def initialize(trigger: nil, content: nil, **options, &blk)
    @trigger = trigger
    @content = content
    @options = options || {}
  end
end