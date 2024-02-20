import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="card"
export default class extends Controller {
  static targets = ["template", "images"]
  connect() {
    if (this.hasImagesTarget) {
      this.imagesTarget.firstChild.firstChild.classList.remove("opacity-0")
    }
  }

  show() {
    const template = this.templateTarget.content.cloneNode(true);
    document.querySelector("#modal").classList.remove("hidden")
    document.querySelector("#modal").appendChild(template)
  }

  quit() {
    document.querySelector("#modal").classList.add("hidden")
    document.querySelector("#modal").innerHTML = ""
  }

  next() {
    const imagesContainer = this.imagesTarget;
    const firstImage = imagesContainer.firstChild;
    const secondImage = imagesContainer.firstChild.nextSibling;

    // Déplacer la première image vers la fin
    secondImage.firstChild.classList.add("opacity-100")
    secondImage.firstChild.classList.remove("opacity-0")
    imagesContainer.removeChild(firstImage);
    imagesContainer.appendChild(firstImage);
    firstImage.firstChild.classList.add("opacity-0")
    firstImage.firstChild.classList.remove("opacity-100")
  }

  previous() {
    const imagesContainer = this.imagesTarget;
    const lastImage = imagesContainer.lastChild;
    const firstImage = imagesContainer.firstChild;

    // Déplacer la première image vers la fin
    firstImage.firstChild.classList.add("opacity-0")
    firstImage.firstChild.classList.remove("opacity-100")
    imagesContainer.removeChild(lastImage);
    imagesContainer.insertBefore(lastImage, firstImage);
    lastImage.firstChild.classList.add("opacity-100")
    lastImage.firstChild.classList.remove("opacity-0")
  }
}
