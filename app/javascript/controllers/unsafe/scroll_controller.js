import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["head", "links"]

  scroll(event) {
    console.log(this.headTarget.offsetHeight);
    if (this.hasLinksTarget) {
      if (event.target.defaultView.pageYOffset > (this.headTarget.offsetHeight)) {
        this.linksTarget.classList.remove("opacity-0");
        this.headTarget.classList.add("opacity-0");
        this.linksTarget.classList.remove("hidden");
      } else {
        this.linksTarget.classList.add("hidden");
        this.linksTarget.classList.add("opacity-0");
        this.headTarget.classList.remove("opacity-0");
      }
    }
  }
}
