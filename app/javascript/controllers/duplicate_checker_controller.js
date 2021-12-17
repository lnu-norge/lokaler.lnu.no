/*
*
* Checks for duplicates in Space#new, and hides part of form until duplication is handled.
*
* */

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="duplicate-checker"
export default class extends Controller {
  static targets = ["duplicatesRenderHere", "hiddenUntilChecked"]

  connect() {
    this.hiddenUntilCheckedTarget.classList.add("hidden")
    const form = this.element
    form.addEventListener('change', () =>  {
      this.checkDuplicates()
    });
  }

  showChecked() {
    this.duplicatesRenderHereTarget.classList.add("hidden")
    this.hiddenUntilCheckedTarget.classList.remove("hidden")
  }

  async checkDuplicates() {
    const data = new FormData(this.element);
    const address = data.get("space[address]");
    const post_number = data.get("space[post_number]");

    if (!post_number || (!address && !post_number)) return
    const title = data.get("space[title]");

    let url = "/check_duplicates?"
        url += `title=${title}&`
        url += `address=${address}&`
        url += `post_number=${post_number}&`

    const result = await (await fetch(url)).json()
    if (result && result.html) {
      this.duplicatesRenderHereTarget.innerHTML = result.html
    }
  }
}
