import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    this.isOpen = false
    this.closeOnEscape = this.closeOnEscape.bind(this)
  }

  open() {
    this.isOpen = true
    this.modalTarget.classList.remove("hidden")
    document.addEventListener("keydown", this.closeOnEscape)
  }

  close() {
    this.isOpen = false
    this.modalTarget.classList.add("hidden")
    document.removeEventListener("keydown", this.closeOnEscape)
  }

  toggle() {
    this.isOpen ? this.close() : this.open()
  }

  closeOnEscape(e) {
    if (e.key === "Escape") this.close()
  }
}
