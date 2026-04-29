import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  open() {
    this.element.classList.remove("hidden")
  }

  close() {
    this.element.classList.add("hidden")
    this.element.dispatchEvent(new CustomEvent("modal:closed", { bubbles: true }))
  }
}
