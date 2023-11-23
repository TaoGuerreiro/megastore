import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "photo" ]

  switch(event) {
    const photoSrc = event.currentTarget.src;
    this.photoTarget.src = photoSrc;
  }
}
