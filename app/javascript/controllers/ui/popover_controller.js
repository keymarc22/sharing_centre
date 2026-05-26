import { Controller } from "@hotwired/stimulus";

export default class UIPopover extends Controller {
  static values = { dismissAfter: Number };
  static targets = ["content", "wrapper", "trigger"];

  connect() {
    this._handleClickOutside = (e) => {
      if (!this.element.contains(e.target)) this.hide();
    };
  }

  disconnect() {
    document.removeEventListener("click", this._handleClickOutside);
  }

  show() {
    this.contentTarget.classList.remove("hidden");
    this.contentTarget.dataset.state = "open";
    document.addEventListener("click", this._handleClickOutside);

    if (this.hasDismissAfterValue) {
      setTimeout(() => this.hide(), this.dismissAfterValue);
    }
  }

  hide() {
    this.contentTarget.classList.add("hidden");
    this.contentTarget.dataset.state = "closed";
    document.removeEventListener("click", this._handleClickOutside);
  }

  toggle(event) {
    event.stopPropagation();
    this.contentTarget.classList.contains("hidden") ? this.show() : this.hide();
  }
}
