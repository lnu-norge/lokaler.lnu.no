import mapboxgl from "mapbox-gl"
import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [9.610, 59.178],
      zoom: 15
    });

    this.map.on('moveend', () => {
      const center = this.map.getBounds().getCenter()
      this.addMarker({lat: center.lat, lng: center.lng, text: "Test Marker"})
    });

  }

  addMarker(marker) {
    const element = document.createElement('div')
    element.className = "rounded p-1 border border-black bg-white"
    element.innerText = marker.text
    new mapboxgl.Marker(element)
      .setLngLat([marker.lng, marker.lat])
      .addTo(this.map)
  }
}
