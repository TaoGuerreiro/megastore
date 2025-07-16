import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["siren", "checkbox", "price"]

  connect() {
    this.toggle()
  }

  toggle() {
    const checked = this.checkboxTarget.checked
    this.sirenTarget.classList.toggle("hidden", !checked)
  }
}
