import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "container"]

  connect() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.items = []
    }
  }

  select(event) {
    this.containerTarget.classList.remove("hidden");

    if (event.currentTarget.checked) {
      this.items.push(event.currentTarget.id)
    } else {
      this.items = this.items.filter(item => item != event.currentTarget.id)
    }
    this.inputTargets.forEach(input => input.value = this.items.join(","))

    if (this.items.length === 0) {
      this.containerTarget.classList.add("hidden");
    }
  }
}
