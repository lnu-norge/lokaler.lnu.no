import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  static targets = [ "wrapper", "background", "modal", "focus", "openButton", "closeButton" ]

  connect() {
    this.connectOpenButton()
    this.connectBackground()
  }

  disconnect() {
    super.disconnect();
    // Enable scrolling on body
    document.body.classList.remove("overflow-hidden")

  }

  connectOpenButton() {
    if (!this.hasOpenButtonTarget) return;

    this.openButtonTarget.onclick = () => this.open()
  }

  connectBackground() {
    if (!this.hasBackgroundTarget) return;

    this.backgroundTarget.onclick = (event) => {
      // Check that we didn't click anything else:
      if (event.target !== this.backgroundTarget) return

      // Then close the modal:
      this.close()
    }
  }

  close() {
    this.wrapperTarget.classList.toggle("hidden")
    // Enable scrolling on body
    document.body.classList.remove("overflow-hidden")
  }

  open() {
    const idToOpen = this.openButtonTarget.dataset.modalToToggle

    const toggleableElement = document.querySelector(
        `[data-modal-id="${idToOpen}"]`
    )

    toggleableElement.classList.toggle("hidden");

    const modalIsOpen = !toggleableElement.classList.contains("hidden");
    if (!modalIsOpen) return;

    // Disable scrolling on body
    document.body.classList.add("overflow-hidden")

    // Focus any elements set to be focused when the modal opens
    const focusMe = toggleableElement.querySelector("[data-modal-focus]")
    if (!focusMe) return;

    focusMe.focus();
  }
}
