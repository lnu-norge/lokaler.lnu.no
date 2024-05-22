import { Controller } from "@hotwired/stimulus"
import Rails from '@rails/ujs';

// Connects to data-controller="autosave-while-typing"
export default class extends Controller {
  connect() {
    this.addStatusElement()
    this.inputListener = this.element.addEventListener('input', this.debouncedSave.bind(this));
    this.onchangeListener = this.element.addEventListener('onchange', this.save.bind(this));
  }
  save() {
    const field = this.element
    const form = field.form

    const formData = new FormData();
    formData.append(field.name, field.value);

    this.setCssClass("saving")

    Rails.ajax({
      url: form.action,
      type: "PATCH",
      data: formData,
      success: () => {
        this.setCssClass("success")
      },
      error: (error) => {
        this.setCssClass("error")
      },
    });
  }

  addStatusElement() {
    this.statusElement = document.createElement("div")
    this.statusElement.classList.add("autosave-while-typing-status")
    this.element.insertAdjacentElement("beforebegin", this.statusElement)
  }

  setCssClass(state) {
    console.log("Setting state", state)
    this.removeCssClasses()
    this.statusElement.classList.add(this.cssClassFor(state))
  }

  removeCssClasses() {
    this.statusElement.classList.remove(this.cssClassFor("saving"))
    this.statusElement.classList.remove(this.cssClassFor("success"))
    this.statusElement.classList.remove(this.cssClassFor("error"))
  }

  cssClassFor(state) {
    return "autosave-while-typing-status--" + state
  }


  debouncedSave() {
    clearTimeout(this.debounceTimeout);
    this.debounceTimeout = setTimeout(() => {
      this.save();
    }, 300);
  }

  disconnect() {
    clearTimeout(this.debouncedSave);
    this.element.removeListener(this.inputListener)
    this.element.removeListener(this.onchangeListener)
    this.statusElement.remove()
  }
}
