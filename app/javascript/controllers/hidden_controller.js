import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="hidden"

// Add the following to a clickable element to
// toggle the class "hidden" on a target:
//    data-controller="hidden"
//    data-hidden-target="toggleButton"
//    data-hidden-id-to-toggle="UNIQUE_TARGET_ID_STRING"
//
// Then add on the target:
//     data-hidden-id="UNIQUE_TARGET_ID_STRING"
export default class extends Controller {
  static targets = ["focus", "toggleButton"]

  connect() {
    this.toggleButtonTarget.addEventListener("click", () => this.toggle())
  }

  toggle() {
    const idToToggle = this.toggleButtonTarget.dataset.hiddenIdToToggle
    const toggleableElement = document.querySelector(
        `[data-hidden-id="${idToToggle}"]`
    )
    toggleableElement.classList.toggle("hidden");

    const elementIsHidden = toggleableElement.classList.contains("hidden");
    if (!elementIsHidden && this.focusTarget) {
      this.focusTarget.focus();
    }
  }
}
