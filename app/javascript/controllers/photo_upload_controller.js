import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["photosContainer"]

  show(e) {
    const input = e.target;
    const files = input.files;
    if (!files) return;

    Array.from(files).forEach((file) => {
      const reader = new FileReader();

      reader.onload = (event) => {
        const mainDiv = document.createElement('div');
        mainDiv.className = 'relative inline-block w-20 h-20 mr-4 bg-contrast rounded-xl'; // Ajoutez des classes de style ici

        const imgElement = document.createElement('img');
        imgElement.src = event.target.result;
        imgElement.className = 'object-cover w-full h-full rounded-xl'; // Ajoutez des classes de style ici

        mainDiv.appendChild(imgElement)
        this.photosContainerTarget.appendChild(mainDiv);
      };

      reader.readAsDataURL(file);
    });
  }
}
