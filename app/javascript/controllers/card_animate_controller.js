import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["card"]

  connect() {
    const firstProjectObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = 1;
        } else {
          entry.target.style.opacity = 0;
        }
      });
    },
    {
      threshold: 0.16
    }
    );
    const secondProjectObserver = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          // entry.target.style.transform = "scale(1)";
        } else {
          // entry.target.style.transform = "scale(1.01)";
        }
      });
    },
    {
      threshold: 0.15
    }
    );
    this.cardTargets.forEach((card, i) => {
      firstProjectObserver.observe(card);
      secondProjectObserver.observe(card);
    });
  }
}
