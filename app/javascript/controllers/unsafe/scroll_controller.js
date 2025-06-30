import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["head", "links"]

  scroll(event) {
    if (this.hasLinksTarget && this.hasHeadTarget) {
      if (event.target.defaultView.pageYOffset > (this.headTarget.offsetHeight)) {
        this.linksTarget.classList.add("bg-light");
      } else {
        this.linksTarget.classList.remove("bg-light");
      }
    }
  }
}
