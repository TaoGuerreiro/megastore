import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["popup", "template"]

  connect() {
    console.log("BacketPopupController connected")
    this.counter = 0
  }

  showPopup() {
    const template = this.templateTarget
    this.counter++
    const clone = template.content.cloneNode(true)
    clone.querySelector(".starburst").textContent = `+${this.counter}`
    this.popupTarget.appendChild(clone)
    this.popupTarget.classList.remove("opacity-0")
    setTimeout(() => {
      this.popupTarget.classList.add("opacity-0", "transition-opacity", "duration-300")
    }, 1000)
  }
}
