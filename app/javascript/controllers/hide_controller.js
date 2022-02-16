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

    if (this.hasFocusableTarget) {
      // For non radio groups, just focus the element:
      if (this.focusableTarget.getAttribute('role') !== "radiogroup") return this.focusableTarget.focus()

      // For radio groups, focus the current checked element:
      this.focusableTarget.querySelector("input[checked]").focus()
    }
  }
}
