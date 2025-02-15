import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  scroll() {
    window.scrollBy({
      top: window.innerHeight,
      left: 0,
      behavior: 'smooth'
    });
  }

  connect() {
    window.addEventListener("scroll", this.toggleVisibility.bind(this));
  }

  disconnect() {
    window.removeEventListener("scroll", this.toggleVisibility.bind(this));
  }

  toggleVisibility() {
    const scrollPosition = window.scrollY;
    const windowHeight = window.innerHeight;

    if (scrollPosition > windowHeight) {
      this.element.classList.add("visible");
    } else {
      this.element.classList.remove("visible");
    }
  }
}
