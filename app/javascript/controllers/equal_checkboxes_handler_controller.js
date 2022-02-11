import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="equal-checkboxes-handler"
export default class extends Controller {
  // Handles the case where a form has multiple check boxes with the same id,
  // by making sure they are all checked

  static targets = ['form']

  connect() {
    const checkboxes = this.formTarget.querySelectorAll('input[type=checkbox]')

    checkboxes.forEach(checkbox => {
      checkbox.onclick = (e) => {
        const clicked_box = e.target
        const same_id = this.formTarget.querySelectorAll(`input[id=${clicked_box.id}]`)
        same_id.forEach(checkbox => checkbox.checked = clicked_box.checked)
      }
    })
  }
}
