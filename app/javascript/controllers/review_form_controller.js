import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-review"
export default class extends Controller {
  static targets = [
      'typeOfContact',
      'fullForm',
      'organizationForm',
      'moreAboutYourStayForm',
      'starRatingForm',
      'textBeenThereForm',
      'titleForm',
      'titleLabelBeenThere',
      'titleLabelNotAllowed'
  ]

  connect() {
    this.disableSubmitButton()
    this.connectTypeOfContact()
  }

  disableSubmitButton() {
    const submit_button = document.getElementById('submit_new_review_button')
    if (!submit_button) return

    submit_button.disabled = true
    submit_button.classList.add('disabled')
  }

  enableSubmitButton() {
    const submit_button = document.getElementById('submit_new_review_button')
    if (!submit_button) return

    submit_button.disabled = false
    submit_button.classList.remove('disabled')
  }

  connectTypeOfContact() {
    const radios = this.typeOfContactTargets

    // Set up change handlers:
    radios.forEach(radio => radio.onclick = (e) => {
        this.typeOfContactChangedTo(e.target.value)
    })

    // If any are checked already, show the correct form:
    radios.forEach(radio => {
      if (radio.checked) {
        this.typeOfContactChangedTo(radio.value)
      }
    })
  }

  typeOfContactChangedTo(typeOfContact) {
    switch(typeOfContact) {
      case "been_there":
        this.showBeenThereForm()
        break;
      case "not_allowed_to_use":
        this.showNotAllowedToUseForm()
        break;
      case "only_contacted":
        this.showOnlyContactedForm()
        break;
      default:
        throw new Error("Unhandled typeOfContact, add to review form controller")
    }

    this.showForm()
  }

  showForm() {
    this.enableSubmitButton()
    this.fullFormTarget.classList.remove('hidden')
  }

  showBeenThereForm() {
    show(this.organizationFormTarget)
    show(this.moreAboutYourStayFormTarget)
    show(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)
    show(this.titleFormTarget)

    show(this.titleLabelBeenThereTarget)
    hide(this.titleLabelNotAllowedTarget)
  }

  showNotAllowedToUseForm() {
    show(this.organizationFormTarget)
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)
    show(this.titleFormTarget)

    hide(this.titleLabelBeenThereTarget)
    show(this.titleLabelNotAllowedTarget)

  }

  showOnlyContactedForm() {
    show(this.organizationFormTarget)
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)

    hide(this.titleFormTarget)

  }
}

function show(element) {
  element.classList.remove('hidden')
}

function hide(element) {
  element.classList.add('hidden')
}
