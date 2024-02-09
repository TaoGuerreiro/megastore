import { Controller } from '@hotwired/stimulus'
// import mapboxgl from 'mapbox-gl';
// import 'mapbox-gl/dist/mapbox-gl.css';

export default class extends Controller {
  // connect() {
  //   this.markers = [];
  //   console.log('ServicePointsController#connect');
  //   mapboxgl.accessToken = 'pk.eyJ1IjoidGFvZ3VlcnJlaXJvIiwiYSI6ImNrdHN6NmY1NzAzcXcyd3F0eGtxZWh2cnIifQ.UlXeCzHtLBuQUEbTMcI44Q';

  //   const map = new mapboxgl.Map({
  //     container: this.element,
  //     style: 'mapbox://styles/mapbox/streets-v11',
  //     duration: 0,
  //   });

  //   const servicePoints = JSON.parse(this.data.get('servicePointsValue'));

  //   servicePoints.forEach(servicePoint => {
  //     const marker = new mapboxgl.Marker()
  //       .setLngLat([servicePoint.longitude, servicePoint.latitude])
  //       .addTo(map);
  //     this.markers.push(marker);
  //   });

  //   this.#fitMapToMarkers(map, this.markers);
  // }

  // #fitMapToMarkers(map, markers) {
  //   const bounds = new mapboxgl.LngLatBounds();
  //   markers.forEach(marker => bounds.extend(marker.getLngLat()));
  //   map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0});
  // }
}
