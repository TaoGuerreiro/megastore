import { Controller } from '@hotwired/stimulus'
import TomSelect from "tom-select";

export default class extends Controller {
  static values = { options: Object }

  connect() {
    console.log(this.optionsValue);
    this.element.classList.remove("form-input")

    const options = { ...this.optionsValue, plugins: { ...this.optionsValue.plugins, remove_button: { title: 'Supprimer' } } };
    console.log(options);
    new TomSelect(this.element, options);
  }
}
