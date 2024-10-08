import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-checkbox-filter"
export default class extends Controller {
  static targets = ["parent", "child", "childrenContainer"]

  initialize() {
    this.toggle = this.toggle.bind(this)
    this.refresh = this.refresh.bind(this)
    this.uncheckAllIfParentIsChecked = this.element.dataset.uncheckAllIfParentIsChecked === "true"
    this.checkAllIfParentIsChecked = this.element.dataset.checkAllIfParentIsChecked === "true"
    this.hideUnlessParentIsChecked = this.element.dataset.hideUnlessParentIsChecked === "true"
  }

  parentTargetConnected(parentCheckbox) {
    parentCheckbox.addEventListener("change", this.toggle)

    this.refresh()
  }

  parentTargetConnectedDisconnected(parentCheckbox) {
    parentCheckbox.removeEventListener("change", this.toggle)

    this.refresh()
  }

  childTargetConnected(childCheckbox) {
    childCheckbox.addEventListener("change", this.refresh)

    this.refresh()
  }

  childTargetDisconnected(childCheckbox) {
    childCheckbox.removeEventListener("change", this.refresh)

    this.refresh()
  }

  toggle(e) {
    e.preventDefault()

    if (this.uncheckAllIfParentIsChecked && this.checked.length === 0) {
      this.parentTarget.checked = true
    }

    if (this.uncheckAllIfParentIsChecked  && this.checked.length > 0) {
      this.parentTarget.checked = true
      this.childTargets.forEach((checkbox) => {
        checkbox.checked = false
        this.triggerInputEvent(checkbox)
      })
    }

    if (this.checkAllIfParentIsChecked || this.parentTarget.checked === false) {
      this.childTargets.forEach((checkbox) => {
        checkbox.checked = e.target.checked
        this.triggerInputEvent(checkbox)
      })
    }

    if (this.hideUnlessParentIsChecked) {
      this.childrenContainerTarget.classList.toggle('hidden', !this.parentTarget.checked)
    }

    this.parentTarget.form.requestSubmit()
  }

  refresh() {
    const checkboxesCount = this.childTargets.length
    const checkboxesCheckedCount = this.checked.length

    if (this.checkAllIfParentIsChecked) {
      this.parentTarget.checked = checkboxesCheckedCount > 0
    }

    if (this.keepParentCheckedIfNoChildIsChecked && checkboxesCheckedCount === 0) {
      this.parentTarget.checked = true
    }

    if (!this.uncheckAllIfParentIsChecked) {
      this.parentTarget.indeterminate = checkboxesCheckedCount > 0 && checkboxesCheckedCount < checkboxesCount
    } else {
      this.parentTarget.checked = checkboxesCheckedCount === 0
    }

    if (this.hideUnlessParentIsChecked) {
      this.childrenContainerTarget.classList.toggle('hidden', !this.parentTarget.checked)
    }
  }

  triggerInputEvent(checkbox) {
    const event = new Event("input", { bubbles: false, cancelable: true })

    checkbox.dispatchEvent(event)
  }

  get checked() {
    return this.childTargets.filter((checkbox) => checkbox.checked)
  }

  get unchecked() {
    return this.childTargets.filter((checkbox) => !checkbox.checked)
  }
}
