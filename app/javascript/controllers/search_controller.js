import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list"]

  connect() {
    console.log('test');
  }

  fetchAddreses = (event) => {
    const { value } = event.currentTarget;
    const url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${value}.json?types=address&country=fr&autocomplete=true&access_token=${this.authToken}`

    fetch(url)
      .then(response => response.json())
      .then((data) => {
        this.listTarget.innerHTML = "";
        this.listTarget.insertAdjacentHTML('beforeend', this.renderList(data.features));
      })
  }

  renderList = (addresses) => {
    const html = `<ul class="z-50 overflow-hidden opacity-100 shadow-lg rounded-lg text-contrast">` +
      addresses.map((address, index) =>
        `<li data-action="click->search#setAddress" class=" !z-50 py-2 px-3 cursor-pointer address last:rounded-b-lg first:rounded-t-lg hover:rounded-lg hover:bg-content list-group-item address" id="address_${index}" data-address="${address.place_name}">${address.place_name}</li>`
      ).join('') +
      `</ul>`
    return html
  }

  setAddress = (event) => {
    const { innerText } = event.target;
    this.inputTarget.value = innerText;
    this.closeList()
  }

  resetInput = () => {
    if (this.hasListTarget) {
      this.closeList()
    }
    this.inputTarget.value = "";
    this.inputTarget.focus()
  }

  closeList = () => {
    this.listTarget.innerHTML = ""
  }

  navigate = (event) => {
    let { currentTarget } = this;
    if (currentTarget === undefined) {
      currentTarget = -1;
    }
    const addresses = document.querySelectorAll(".address");
    const max = addresses.length;
    const { key } = event;

    if (key === "ArrowUp") {
      this.removeFocus(addresses);
      currentTarget
      currentTarget--;
      currentTarget = currentTarget <= -1 ? max - 1 : currentTarget;
      addresses[currentTarget].classList.toggle('bg-blue-bici', true);
      addresses[currentTarget].classList.toggle('text-contrast', true);
    } else if (key === "ArrowDown") {
      this.removeFocus(addresses);
      currentTarget++;
      currentTarget = currentTarget > max - 1 ? 0 : currentTarget;
      addresses[currentTarget].classList.toggle('bg-blue-bici', true);
      addresses[currentTarget].classList.toggle('text-contrast', true);
    } else if (key === "Enter") {
      event.preventDefault();
      const input = addresses[currentTarget];
      if (!input) {
        return;
      }
      const address = input.innerText;
      this.inputTarget.value = address;
      this.closeList();
    }
    this.currentTarget = currentTarget;
  }

  removeFocus = (addresses) => {
    addresses.forEach((address) => {
      address.classList.toggle('bg-blue-bici', false);
      address.classList.toggle('text-contrast', false);
    })
  }

  get authToken() {
    return document.head.querySelector('meta[name="mapbox_token"]').content;
  }
}
