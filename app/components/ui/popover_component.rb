class Ui::PopoverComponent < ApplicationComponent

  attr_reader :options, :inner_block

  def initialize(trigger: nil, content: nil, items: nil, **options, &block)
    @trigger = trigger
    @content = content
    @items = items
    @options = options || {}
    @inner_block = block
  end

end