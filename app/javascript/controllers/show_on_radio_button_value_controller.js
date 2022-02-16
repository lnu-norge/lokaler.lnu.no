import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-on-radio-button-value"
export default class extends Controller {
  static targets = [ "radioButton", "toggleOnChecked", "elementToShow" ]

  connect() {
    const element = this.elementToShowTarget
    const radioButtons = this.radioButtonTargets
    const toggleOnChecked = this.toggleOnCheckedTarget

    if (!toggleOnChecked.checked) {
      element.classList.add('hidden')
    }

    radioButtons.forEach(radioButton => radioButton.onchange = () => {
      if (toggleOnChecked.checked) {
        // If checked, show and focus:
        element.classList.remove('hidden')
        element.querySelector('input').focus()
      } else {
        // If not checked, hide and remove any content:
        element.querySelector('input').value = ''
        return element.classList.add('hidden')
      }
    })
  }
}
