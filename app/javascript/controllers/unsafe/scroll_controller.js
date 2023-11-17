import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["head", "links"]

  scroll(event) {
    if (this.hasLinksTarget && this.hasHeadTarget) {
      if (event.target.defaultView.pageYOffset > (this.headTarget.offsetHeight)) {
        this.headTarget.classList.add("opacity-0");
        this.linksTarget.classList.remove("hidden");
      } else {
        this.linksTarget.classList.add("hidden");
        this.headTarget.classList.remove("opacity-0");
      }
    }
  }
}
