import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "messages"]

  connect() {
    this.scrollToBottom()
    this.setupObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    if (this.hasContainerTarget) {
      this.containerTarget.scrollTop = this.containerTarget.scrollHeight
    }
  }

  setupObserver() {
    if (!this.hasMessagesTarget) return

    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          // Attendre un peu pour que le DOM soit mis à jour
          setTimeout(() => this.scrollToBottom(), 100)
        }
      })
    })

    this.observer.observe(this.messagesTarget, {
      childList: true,
      subtree: true
    })
  }
}
