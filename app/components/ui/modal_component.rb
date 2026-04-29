module Ui
  class ModalComponent < ApplicationComponent
    def initialize(klass: "", open: false)
      @klass = klass
      @open = open
    end
  end
end
