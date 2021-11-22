import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multistep_form"
export default class extends Controller {
  static targets = ["step", "next", "previous", "save"];

  connect() {
    this.steps = 0;
    this.update();
  }

  previousStep() {
    if(this.steps == 0) {
      return;
    }

    this.steps -= 1;
    this.update();
  }

  nextStep() {
    if(this.steps == this.stepTargets.length - 1) {
      return;
    }

    this.steps += 1;
    this.update();
  }

  update() {
    this.stepTargets.forEach(step => {
      this.hide(step);
    });

    this.show(this.stepTargets[this.steps]);

    this.hide(this.saveTarget);

    if(this.steps == 0) {
      this.hide(this.previousTarget);
    }
    else {
      this.show(this.previousTarget);
    }

    if(this.steps == this.stepTargets.length - 1) {
      this.hide(this.nextTarget);
      this.show(this.saveTarget);
    }
    else {
      this.show(this.nextTarget);
    }
  }

  hide(step) {
    step.classList.add("hidden");
  }

  show(step) {
    step.classList.remove("hidden");
  }
}
