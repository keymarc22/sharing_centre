import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  open() {
    this.panelTarget.classList.add("sidebar-open")
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("sidebar-active")
  }

  close() {
    this.panelTarget.classList.remove("sidebar-open")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("sidebar-active")
  }

  toggle() {
    if (this.panelTarget.classList.contains("sidebar-open")) {
      this.close()
    } else {
      this.open()
    }
  }
}
