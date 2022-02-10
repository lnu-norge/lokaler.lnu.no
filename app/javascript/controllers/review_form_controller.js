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
      'titleLabelBeenThere',
      'titleLabelNotAllowed',
      'titleLabelOnlyContacted'
  ]

  connect() {
    console.log("hi", this.typeOfContactTargets)
    this.connectTypeOfContact()
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
    this.fullFormTarget.classList.remove('hidden')
  }

  showBeenThereForm() {
    show(this.organizationFormTarget)
    show(this.moreAboutYourStayFormTarget)
    show(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)

    show(this.titleLabelBeenThereTarget)
    hide(this.titleLabelNotAllowedTarget)
    hide(this.titleLabelOnlyContactedTarget)
  }

  showNotAllowedToUseForm() {
    show(this.organizationFormTarget)
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)

    hide(this.titleLabelBeenThereTarget)
    show(this.titleLabelNotAllowedTarget)
    hide(this.titleLabelOnlyContactedTarget)

  }

  showOnlyContactedForm() {
    show(this.organizationFormTarget)
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    show(this.textBeenThereFormTarget)

    hide(this.titleLabelBeenThereTarget)
    hide(this.titleLabelNotAllowedTarget)
    show(this.titleLabelOnlyContactedTarget)

  }
}

function show(element) {
  element.classList.remove('hidden')
}

function hide(element) {
  element.classList.add('hidden')
}
