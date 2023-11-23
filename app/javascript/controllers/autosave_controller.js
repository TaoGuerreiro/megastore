import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["button"]

  save() {
    console.log("save");
    this.buttonTarget.click()
  }
}
