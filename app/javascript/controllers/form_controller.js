import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleGroup(event) {
    event.target.closest('.group').classList.toggle('checked')
  }
}
