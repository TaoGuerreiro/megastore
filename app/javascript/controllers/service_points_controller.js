import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['map']
  connect() {
    this.markers = [];
    console.log('ServicePointsController#connect');
    mapboxgl.accessToken = this.authToken;

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v11',
      duration: 0,
    });

    const servicePoints = JSON.parse(this.data.get('servicePointsValue'));

    servicePoints.forEach(servicePoint => {
      const element = document.createElement('div');
      element.className = 'relative flex justify-center rounded-full bg-primary item-center';
      element.id = servicePoint.id
      let spanElement = document.createElement('span');
      spanElement.classList = "w-6 h-6 text-contour flex justify-center items-center"
      spanElement.innerText = servicePoint.index;
      element.insertBefore(spanElement, element.firstChild)

      const popup = new mapboxgl.Popup()
        .setHTML(servicePoint.info_window_html)
        .setMaxWidth("none");

      popup._closeButton.classList.add("hidden")

      const marker = new mapboxgl.Marker(element)
        .setLngLat([servicePoint.longitude, servicePoint.latitude])
        .setPopup(popup)
        .addTo(this.map);
      this.markers.push(marker);
    });

    this.#fitMapToMarkers(this.map, this.markers);
  }

  show(event) {
    const point = JSON.parse(event.target.dataset.point)

    // const markers = document.querySelectorAll(`.mapboxgl-marker`)
    const hovered_marker = document.getElementById(point.id)

    this.markers.forEach((marker) =>{
      marker._element.classList.add("!opacity-0")
    })

    hovered_marker.classList.remove("!opacity-0")

    // debugger
    this.markers.forEach((marker) => {
      marker.getPopup().remove()
    });
    console.log(point.index);
    this.markers[point.index - 1].togglePopup()

    // je veux ouvrir la popup du hovered_marker
    // const pointBound = { lng: point.longitude, lat: point.latitude }
    // const bounds = new mapboxgl.LngLatBounds(pointBound, pointBound);

    // this.map.fitBounds(bounds, {
    //   padding: 100,
    //   maxZoom: 15,
    //   duration: 400
    // });
  }

  showAll(event) {
    this.markers.forEach((marker) =>{
      marker.getPopup().remove()
      marker._element.classList.remove("!opacity-0")
    })
  }

  #fitMapToMarkers(map, markers) {
    const bounds = new mapboxgl.LngLatBounds();
    markers.forEach(marker => bounds.extend(marker.getLngLat()));
    map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0});
  }

  get authToken() {
    return document.head.querySelector('meta[name="mapbox_token"]').content;
  }
}
