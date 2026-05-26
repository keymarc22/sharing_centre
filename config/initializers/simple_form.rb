# frozen_string_literal: true

SimpleForm.setup do |config|
  config.wrappers :default, class: "flex flex-col gap-1.5 mb-4",
    hint_class: :field_with_hint, error_class: :field_with_errors, valid_class: :field_without_errors do |b|
    b.use :html5
    b.use :placeholder

    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.use :label, class: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    b.use :input,
      class: "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 file:border-0 file:bg-transparent file:text-sm file:font-medium transition-colors",
      error_class: "border-destructive focus-visible:ring-destructive",
      valid_class: ""
    b.use :hint,  wrap_with: { tag: :p, class: "text-xs text-muted-foreground" }
    b.use :error, wrap_with: { tag: :p, class: "text-xs text-destructive" }
  end

  config.wrappers :check_boxes, tag: :fieldset, class: "flex flex-col gap-1.5 mb-4",
    hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.wrapper tag: :div, class: "flex items-center gap-2" do |ba|
      ba.use :input, class: "h-4 w-4 rounded border-input text-primary focus:ring-2 focus:ring-ring focus:ring-offset-2"
      ba.use :label, class: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    end
    b.use :hint,  wrap_with: { tag: :p, class: "text-xs text-muted-foreground" }
    b.use :error, wrap_with: { tag: :p, class: "text-xs text-destructive" }
  end

  config.wrappers :radio_buttons, tag: :fieldset, class: "flex flex-col gap-2 mb-4",
    hint_class: :field_with_hint, error_class: :field_with_errors do |b|
    b.use :html5
    b.wrapper tag: :div, class: "flex items-center gap-2" do |ba|
      ba.use :input, class: "h-4 w-4 border-input text-primary focus:ring-2 focus:ring-ring focus:ring-offset-2"
      ba.use :label, class: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    end
    b.use :hint,  wrap_with: { tag: :p, class: "text-xs text-muted-foreground" }
    b.use :error, wrap_with: { tag: :p, class: "text-xs text-destructive" }
  end

  config.default_wrapper = :default

  config.boolean_style = :nested

  config.button_class = "btn"

  config.error_notification_tag = :div
  config.error_notification_class = "p-3 mb-4 text-sm text-destructive bg-destructive/10 rounded-md border border-destructive/20"

  config.browser_validations = false

  config.boolean_label_class = "checkbox"

  config.wrapper_mappings = {
    boolean:      :check_boxes,
    radio_button: :radio_buttons
  }
end
