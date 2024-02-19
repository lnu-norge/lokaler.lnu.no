import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="new-review"
export default class extends Controller {
  static targets = [
      'typeOfContact',
      'fullForm',
      'organizationForm',
      'moreAboutYourStayForm',
      'starRatingForm',
      'commentForm',
      'commentLabelBeenThere',
      'commentLabelNotAllowed',
      'commentLabelOnlyContacted',
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
    show(this.organizationFormTarget)
    show(this.fullFormTarget)
  }

  showBeenThereForm() {
    show(this.moreAboutYourStayFormTarget)
    show(this.starRatingFormTarget)
    this.showHideCommentSectionFor('BeenThere')
  }

  showNotAllowedToUseForm() {
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    this.showHideCommentSectionFor('NotAllowed')
  }

  showOnlyContactedForm() {
    hide(this.moreAboutYourStayFormTarget)
    hide(this.starRatingFormTarget)
    this.showHideCommentSectionFor('OnlyContacted')
  }

  showHideCommentSectionFor(typeOfContact) {
    // typeOfContact needs to be one of: OnlyContacted, BeenThere, NotAllowed

    const commentTargets = {
        BeenThere: this.commentLabelBeenThereTarget,
        NotAllowed: this.commentLabelNotAllowedTarget,
        OnlyContacted: this.commentLabelOnlyContactedTarget,
    }
    const current = commentTargets[typeOfContact]
    const others = Object.values(commentTargets).filter(label => label !== current)

    others.forEach(hide)
    show(current)

    show(this.commentFormTarget)
  }
}

function show(element) {
  console.log("showing", element)
  element.classList.remove('hidden')
}

function hide(element) {
  console.log("hiding", element)
  element.classList.add('hidden')
}
