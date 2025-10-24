import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle-password"
export default class extends Controller {
  static targets = ["password", "toggle"]

  toggle() {
    const input = this.passwordTarget
    input.type = input.type === "password" ? "text" : "password"
    if (this.hasToggleTarget) this.toggleTarget.classList.toggle("active")
  }
}
