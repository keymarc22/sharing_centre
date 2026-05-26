import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "fields", "countField", "untilField"]

  toggle() {
    if (this.toggleTarget.checked) {
      this.fieldsTarget.classList.remove("hidden")
    } else {
      this.fieldsTarget.classList.add("hidden")
    }
  }

  handleUntil() {
    if (this.untilFieldTarget.value) {
      this.countFieldTarget.querySelector("input").value = ""
    }
  }
}
