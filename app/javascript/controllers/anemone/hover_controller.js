import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["button"]

  scale(event) {
    event.currentTarget.classList.remove("w-1/6", "grow", "grayscale");
    event.currentTarget.classList.add("w-1/2");
  }

  unscale(event) {
    event.currentTarget.classList.add("w-1/6", "grow", "grayscale");
    event.currentTarget.classList.remove("w-1/2");
  }
}
