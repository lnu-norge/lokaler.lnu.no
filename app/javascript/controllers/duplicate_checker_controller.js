/*
*
* Checks for duplicates in Space#new, and hides part of form until duplication is handled.
*
* */

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="duplicate-checker"
export default class extends Controller {

  connect() {
    const form = this.element
    form.addEventListener('change', () =>  {
      this.check_duplicates()
    });
  }

  check_duplicates() {
    const data = new FormData(this.element);
    const title = data.get("space[title]");
    const address = data.get("space[address]");
    const post_number = data.get("space[post_number]");
  }
}
