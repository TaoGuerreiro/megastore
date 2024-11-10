import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="card"
export default class extends Controller {
  static targets = ["template", "images", "dots"]
  connect() {
    if (this.hasImagesTarget) {
      debugger
      this.imagesTarget.firstChild.firstChild.classList.remove("opacity-0")
      this.dotsTarget.firstChild.classList.add("!bg-secondary")
    }
  }

  show() {
    const template = this.templateTarget.content.cloneNode(true);
    document.querySelector("#card-modal").classList.remove("hidden")
    document.querySelector("#card-modal").appendChild(template)
  }

  quit() {
    document.querySelector("#card-modal").classList.add("hidden")
    document.querySelector("#card-modal").innerHTML = ""
  }

  next() {
    const imagesContainer = this.imagesTarget;
    const firstImage = imagesContainer.firstChild;
    const secondImage = imagesContainer.firstChild.nextSibling;

    const dotsContainer = this.dotsTarget;
    const currentDot = dotsContainer.querySelector(".active") || dotsContainer.firstChild;
    currentDot.classList.remove("active");
    const nextDot = currentDot.nextSibling || dotsContainer.firstChild;
    nextDot.classList.add("active");
    currentDot.classList.remove("!bg-secondary")
    nextDot.classList.add("!bg-secondary")

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

    const dotsContainer = this.dotsTarget;
    const currentDot = dotsContainer.querySelector(".active") || dotsContainer.firstChild;
    currentDot.classList.remove("active");
    const previousDot = currentDot.previousSibling || dotsContainer.lastChild;
    previousDot.classList.add("active");
    currentDot.classList.remove("!bg-secondary")
    previousDot.classList.add("!bg-secondary")


    // Déplacer la première image vers la fin
    firstImage.firstChild.classList.add("opacity-0")
    firstImage.firstChild.classList.remove("opacity-100")
    imagesContainer.removeChild(lastImage);
    imagesContainer.insertBefore(lastImage, firstImage);
    lastImage.firstChild.classList.add("opacity-100")
    lastImage.firstChild.classList.remove("opacity-0")
  }
}
