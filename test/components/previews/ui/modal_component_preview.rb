# @label Modal
module Ui
  class ModalComponentPreview < ViewComponent::Preview

    # @label Default (empty)
    def default
      render Ui::ModalComponent.new(open: true)
    end

    # @label With content
    def with_content
      render Ui::ModalComponent.new(open: true) do
        "<div>
          <h2 class='text-lg font-semibold mb-2'>Modal title</h2>
          <p class='text-sm text-muted-foreground'>This is the modal body content. You can place any HTML here.</p>
        </div>".html_safe
      end
    end

    # @label Confirmation dialog
    def confirmation
      render Ui::ModalComponent.new(open: true) do
        "<div class='space-y-4'>
          <div>
            <h2 class='text-lg font-semibold'>Are you sure?</h2>
            <p class='text-sm text-muted-foreground mt-1'>This action cannot be undone.</p>
          </div>
          <div class='flex justify-end gap-2'>
            <button class='inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors h-9 px-4 text-sm border border-input bg-background hover:bg-accent hover:text-accent-foreground'>
              Cancel
            </button>
            <button class='inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors h-9 px-4 text-sm bg-destructive text-destructive-foreground hover:bg-destructive/90'>
              Confirm
            </button>
          </div>
        </div>".html_safe
      end
    end

    # @label Form dialog
    def form_dialog
      render Ui::ModalComponent.new(open: true) do
        "<div class='space-y-4'>
          <h2 class='text-lg font-semibold'>Edit profile</h2>
          <div class='space-y-2'>
            <label class='text-sm font-medium'>Name</label>
            <input type='text' placeholder='Your name' class='flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm' />
          </div>
          <div class='space-y-2'>
            <label class='text-sm font-medium'>Email</label>
            <input type='email' placeholder='your@email.com' class='flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm' />
          </div>
          <div class='flex justify-end'>
            <button class='inline-flex items-center justify-center gap-2 rounded-md font-medium transition-colors h-9 px-4 text-sm bg-primary text-primary-foreground hover:bg-primary/80'>
              Save changes
            </button>
          </div>
        </div>".html_safe
      end
    end

    # @label With custom class
    def with_custom_class
      render Ui::ModalComponent.new(open: true, klass: "opacity-95") do
        "<div>
          <h2 class='text-lg font-semibold mb-2'>Custom class modal</h2>
          <p class='text-sm text-muted-foreground'>This modal uses a custom overlay class.</p>
        </div>".html_safe
      end
    end
  end
end
