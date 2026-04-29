# frozen_string_literal: true

module Ui
  class ButtonComponent < ApplicationComponent
    VARIANTS = {
      primary:     "bg-primary text-primary-foreground hover:bg-primary/80",
      secondary:   "bg-secondary text-secondary-foreground hover:bg-secondary/80",
      destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      success:     "bg-success text-success-foreground hover:bg-success/80",
      outline:     "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
      ghost:       "hover:bg-accent hover:text-accent-foreground",
      link:        "text-primary underline-offset-4 hover:underline"
    }.freeze

    SIZES = {
      sm:      "h-8 px-3 text-xs",
      md:      "h-9 px-4 text-sm",
      lg:      "h-10 px-6 text-base",
      icon:    "h-9 w-9 p-0"
    }.freeze

    BASE_CLASSES = "inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"

    def initialize(
      variant: :primary,
      size: :md,
      tag: :button,
      type: "button",
      href: nil,
      klass: "",
      **html_attrs
    )
      @variant    = variant.to_sym
      @size       = size.to_sym
      @tag        = href ? :a : tag.to_sym
      @type       = type
      @href       = href
      @klass      = klass
      @html_attrs = html_attrs
    end

    def button_attrs
      attrs = @html_attrs.merge(class: tw(BASE_CLASSES, VARIANTS.fetch(@variant, VARIANTS[:primary]), SIZES.fetch(@size, SIZES[:md]), @klass))
      attrs[:href] = @href if @href
      attrs[:type] = @type if @tag == :button
      attrs
    end
  end
end
