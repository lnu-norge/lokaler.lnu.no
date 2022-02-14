import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hide"
export default class extends Controller {
  static targets = ["hideable", "focusable"]

  connect() {
    if (!this.hideableTarget) {
      return console.error("Missing hideable target for hide controller")
    }
  }

  toggleHidden() {
    const hideable = this.hideableTarget
    hideable.classList.toggle("hidden")

    if (hideable.classList.contains("hidden")) return;

    if (this.focusableTarget) {
      this.focusableTarget.focus()
    }
  }
}
