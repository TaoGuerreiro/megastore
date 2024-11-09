import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("coucou");
  }

  scroll() {
    window.scrollBy({
      top: window.innerHeight,
      left: 0,
      behavior: 'smooth'
    });
  }
}
