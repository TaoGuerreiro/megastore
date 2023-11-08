import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // document.addEventListener('turbo:load', this.replaceClasses);
    // document.addEventListener('turbo:render', this.replaceClasses);
  }

  replaceClasses() {
    // const replacers = document.querySelectorAll('[data-replace]');
    // for (let replacer of replacers) {
    //   const replaceClasses = JSON.parse(replacer.dataset.replace.replace(/'/g, `"`));
    //   Object.entries(replaceClasses).forEach(([key, value]) => {
    //     if (replacer.classList.contains(key)) {
    //       replacer.classList.replace(key, value);
    //     } else {
    //       replacer.classList.add(value);
    //     }
    //   });
    // }
  }
}
