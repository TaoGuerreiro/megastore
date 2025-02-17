import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["element"];

  connect() {
    window.addEventListener("mousemove", this.handleMouseMove);
  }

  disconnect() {
    window.removeEventListener("mousemove", this.handleMouseMove);
  }

  handleMouseMove = (event) => {
    const x = event.clientX;
    const y = event.clientY;

    // Trouver le centre de l'écran
    const middleX = window.innerWidth / 2;
    const middleY = window.innerHeight / 2;

    // Calculer l'écart par rapport au centre (en %)
    const offsetX = ((x - middleX) / middleX) * 5;
    const offsetY = ((y - middleY) / middleY) * 5;

    // Appliquer la rotation via CSS variables
    this.elementTarget.style.setProperty("--rotateX", `${offsetX}deg`);
    this.elementTarget.style.setProperty("--rotateY", `${-offsetY}deg`);
  };
}
