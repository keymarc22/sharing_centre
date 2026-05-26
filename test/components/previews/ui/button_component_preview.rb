# @label Button
module Ui
  class ButtonComponentPreview < ViewComponent::Preview

    # @!group Colors
    # @label Primary
    def primary
      render Ui::ButtonComponent.new(variant: :primary).with_content("Primary")
    end

    # @label Secondary
    def secondary
      render Ui::ButtonComponent.new(variant: :secondary).with_content("Secondary")
    end

    # @label Destructive
    def destructive
      render Ui::ButtonComponent.new(variant: :destructive).with_content("destructive")
    end

    # @label Success
    def success
      render Ui::ButtonComponent.new(variant: :success).with_content("success")
    end

    # @label Outline
    def outline
      render Ui::ButtonComponent.new(variant: :outline).with_content("outline")
    end

    # @label Ghost
    def ghost
      render Ui::ButtonComponent.new(variant: :ghost).with_content("ghost")
    end

    # @!endgroup

    # @!group Sizes
    # @label Small
    def size_sm
      render Ui::ButtonComponent.new(size: :sm).with_content("Small")
    end

    # @label Medium
    def size_md
      render Ui::ButtonComponent.new(size: :md).with_content("Medium")
    end

    # @label Large
    def size_lg
      render Ui::ButtonComponent.new(size: :lg).with_content("Large")
    end

    # @label Icon
    def size_icon
      render Ui::ButtonComponent.new(size: :icon).with_content("★")
    end
    # @!endgroup

    # @label Link
    def link
      render Ui::ButtonComponent.new(variant: :link).with_content("link")
    end

    # @label As anchor
    def as_anchor
      render Ui::ButtonComponent.new(variant: :primary, href: "#").with_content("Go somewhere")
    end

    # @label Disabled
    def disabled
      render Ui::ButtonComponent.new(variant: :primary, disabled: true).with_content("Disabled")
    end
  end
end
