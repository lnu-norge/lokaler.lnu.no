/*
*
* Checks for duplicates in Space#new, and hides part of form until duplication is handled.
*
* */

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="duplicate-checker"
export default class extends Controller {
  static targets = [
    "duplicatesRenderHere",
    "hiddenUntilChecked",
    "ignoreDuplicatesButton",
    "showDuplicatesButton",
    "duplicates"
  ]

  state = {
    title: "",
    address: "",
    post_number: ""
  }

  connect() {
    const form = this.element
    this.hideRestOfForm()
    form.addEventListener('change', () =>  {
      this.checkDuplicates()
    });
  }

  async checkDuplicates() {
    const data = new FormData(this.element);
    const address = data.get("space[address]");
    const post_number = data.get("space[post_number]");

    if (!post_number || (!address && !post_number)) return
    const title = data.get("space[title]");

    if (this.checkIfDataIsStale(title, address, post_number)) {
      return
    }

    let url = "/check_duplicates?"
        url += `title=${title}&`
        url += `address=${address}&`
        url += `post_number=${post_number}&`

    const result = await (await fetch(url)).json()
    if (result && result.html) {
      this.hideRestOfForm()
      return this.duplicatesRenderHereTarget.innerHTML = result.html
    }

    return this.showRestOfForm()
  }

  checkIfDataIsStale(title, address, post_number) {
    if (title !== this.state.title || address !== this.state.address || post_number !== this.state.post_number) {
      this.state.title = title
      this.state.address = address
      this.state.post_number = post_number
      return false
    }
    return true
  }

  hideRestOfForm() {
    this.stopFormSubmit()
    show(this.duplicatesRenderHereTarget)
    hide(this.hiddenUntilCheckedTarget)
  }

  showRestOfForm() {
    this.enableFormSubmit()
    hide(this.duplicatesRenderHereTarget)
    show(this.hiddenUntilCheckedTarget)
  }

  ignoreDuplicates() {
    this.enableFormSubmit()
    show(this.showDuplicatesButtonTarget)
    show(this.hiddenUntilCheckedTarget)
    hide(this.ignoreDuplicatesButtonTarget)
    hide(this.duplicatesTarget)
  }

  unIgnoreDuplicates() {
    this.stopFormSubmit()
    hide(this.showDuplicatesButtonTarget)
    show(this.ignoreDuplicatesButtonTarget)
    show(this.duplicatesTarget)
  }

  stopFormSubmit() {
    this.element.querySelector("input[type=submit]").disabled = true
  }

  enableFormSubmit() {
    this.element.querySelector("input[type=submit]").disabled = false
  }

}

const hide = (element) => {
  element.classList.add("hidden")
}

const show = (element) => {
  element.classList.remove("hidden")
}
