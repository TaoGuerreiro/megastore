import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("tw-hidden")

    document.addEventListener("click", (event) => {
      if (!this.element.contains(event.target)) {
        this.hide()
      }
    })
  }

  hide() {
    this.menuTarget.classList.add("tw-hidden")
  }
}
