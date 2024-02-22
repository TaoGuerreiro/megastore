import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "address", "city", "postalCode", "country", "input", "streetNumber" ]

  connect() {
    this.geocoder = new MapboxGeocoder({
      accessToken: this.authToken,
      types: 'address',
      mapboxgl: false
    })

    this.geocoder.on('result', (event) => {
      this.updateAddressFields(event)
    })

    const geocoderElement = this.geocoder.onAdd()
    this.inputTarget.appendChild(geocoderElement)

    geocoderElement.classList.add('!w-full', '!max-w-none')
  }

  updateAddressFields(event) {
    this.postalCodeTarget.value = event.result.context.find(c => c.id.startsWith('postcode')).text
    this.cityTarget.value = event.result.context.find(c => c.id.startsWith('place')).text
    this.countryTarget.value = event.result.context.find(c => c.id.startsWith('country')).short_code.toUpperCase()
    if (event.result.address != undefined) {
      this.streetNumberTarget.value = event.result.address;
    }
    this.addressTarget.value = event.result.text
  }

  get authToken() {
    return document.head.querySelector('meta[name="mapbox_token"]').content;
  }
}
