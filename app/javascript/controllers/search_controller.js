import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {

  static targets = ["form"]

  connect() {

  }

  disableFilterById(event) {
    console.log("disableFilterById", event)
    const idToClear = event.target.dataset.idToClear

    if (idToClear) {
      this.formTarget.querySelector(`#${idToClear}`).value = ''
    }

    this.formTarget.requestSubmit()
  }
}
