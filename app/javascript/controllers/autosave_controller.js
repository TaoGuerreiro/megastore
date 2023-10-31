import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["button"]

  connect() {
    console.log("coucou");
  }

  save() {
    console.log("save");
    this.buttonTarget.click()
  }
}
