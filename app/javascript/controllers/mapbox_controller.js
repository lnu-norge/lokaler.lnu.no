import mapboxgl from "mapbox-gl"
import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [9.610, 59.178],
      zoom: 9
    });

    /*
    this.map.on('moveend', () => {
      const center = this.map.getBounds().getCenter()
      this.addMarker({lat: center.lat, lng: center.lng, text: "Test Marker"})
    });
    */

    const markers = JSON.parse(this.element.dataset.markers)

    markers.forEach(marker => {
      this.addMarker(marker)
    });
  }

  addMarker(marker) {
    const element = document.createElement('div')
    element.className = "rounded-md py-1 px-2 border border-gray-400 bg-white shadow-lg"
    element.innerText = marker.title
    new mapboxgl.Marker(element)
      .setLngLat([marker.lng, marker.lat])
      .addTo(this.map)
  }
}
