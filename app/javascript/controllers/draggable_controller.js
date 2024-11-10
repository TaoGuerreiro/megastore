import { Controller } from "@hotwired/stimulus"
import {Sortable, Plugins} from '@shopify/draggable';

export default class extends Controller {
  static targets = ["card", "container"];

  connect() {
    if (this.containerTargets.length === 0) {
      return false;
    }

    const sortable = new Sortable(this.containerTargets, {
      draggable: '.card',
      handle: '.handle',
      mirror: {
        constrainDimensions: true,
      },
      plugins: [Plugins.ResizeMirror],
    });

    sortable.on('sortable:stop', (evt) => {
      setTimeout(() => {
        this.computePostions(evt.oldContainer)
        this.computePostions(evt.newContainer)
      }, 200);
    });
  }

  computePostions(container) {
    const positionX = container.getAttribute('data-position-x');
    container.querySelectorAll('.card').forEach((card, index) => {
      let id = card.getAttribute('data-card-id');
      card.setAttribute('data-position-x', positionX);
      card.setAttribute('data-position-y', index);

      const form = card.querySelector('.position-form');

      form.querySelector('[name="carousel_card[position_x]"]').value = positionX;
      form.querySelector('[name="carousel_card[position_y]"]').value = index;

      setTimeout(() => {
        form.requestSubmit();
      }, 300);
    });
  }
}
