import { Controller } from '@hotwired/stimulus'
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    console.log("oui");
    this.element.classList.remove("form-input")
    new TomSelect(this.element, {
      // options de Tom Select
      plugins: {
        remove_button:{
          title:'Remove this item',
        }
      },
    });
  }
}
