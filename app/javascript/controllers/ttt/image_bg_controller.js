import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.setHeight()
    window.addEventListener('resize', this.setHeight.bind(this))
  }

  disconnect() {
    window.removeEventListener('resize', this.setHeight.bind(this))
  }

  setHeight() {
    const url = this.urlValue
    if (!url) return

    const img = new window.Image()
    img.onload = () => {
      const ratio = img.height / img.width
      const width = this.element.offsetWidth
      this.element.style.height = `${width * ratio}px`
    }
    img.src = url
  }
}
