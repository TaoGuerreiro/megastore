import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosave"
export default class extends Controller {
  static targets = ["t"]

  connect() {
    this.animateTargetsSequentially(0); // Commencez avec le premier élément
    this.distance = 100;
    document.addEventListener('mousemove', (event) => {
      // Récupérer la largeur et la hauteur de la fenêtre
      const centerX = window.innerWidth / 2;
      const centerY = window.innerHeight / 2;

      // Récupérer la position de la souris
      const mouseX = event.clientX;
      const mouseY = event.clientY;

      // Calculer la distance entre la souris et le centre de la page
      const distanceX = Math.abs(centerX - mouseX);
      const distanceY = Math.abs(centerY - mouseY);

      // Utiliser le théorème de Pythagore pour calculer la distance diagonale
      const distance = Math.sqrt(distanceX * distanceX + distanceY * distanceY);

      this.distance = distance;
    });
  }

  animateTargetsSequentially(index) {
    if (index < this.tTargets.length) {
      this.index = index;
      const t = this.tTargets[index];
      t.classList.remove('opacity-0');
      setTimeout(() => {
        t.classList.add('opacity-0');
        this.animateTargetsSequentially(index + 1);
      }, this.distance);
    } else {
      this.animateTargetsSequentially(0);
    }
  }
}
