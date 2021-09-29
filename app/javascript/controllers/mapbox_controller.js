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

    this.markers = []

    this.map.on('moveend', () => {
      this.loadMarkers()
    });

    this.loadMarkers()
  }

  addMarker(marker) {
    const element = document.createElement('div')
    element.className = "rounded-md py-1 px-2 border border-gray-400 bg-white shadow-lg"
    element.innerText = marker.title
    this.markers.push(new mapboxgl.Marker(element)
      .setLngLat([marker.lng, marker.lat])
      .addTo(this.map))
  }

  loadMarkers() {
    this.markers.forEach((marker) => {
      marker.remove()
    })
    this.markers = []

    const northWest = this.map.getBounds().getNorthWest()
    const southEast = this.map.getBounds().getSouthEast()
    fetch(`/spaces_in_rect?north_west_lat=${northWest.lat}&north_west_lng=${northWest.lng}&south_east_lat=${southEast.lat}&south_east_lng=${southEast.lng}`)
      .then(response => response.text())
      .then(json => {
        const markers = JSON.parse(json)
        markers.forEach(marker => {
          this.addMarker(marker)
        });
      })
  }
}
