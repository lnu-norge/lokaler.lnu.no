import mapboxgl from 'mapbox-gl';
import { Controller } from 'stimulus';

export default class extends Controller {
  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [10.925860, 59.223840],
      zoom: 11,
    });

    this.map.on('moveend', () => {
      this.loadNewMapPosition();
    });

    // Hash for storing markers, based on
    // { spaceId: mapBoxMarker }
    this.markers = {};

    this.loadNewMapPosition();
  }

  addMarker(space) {
    // If marker is already added, then just update that element, otherwise, create a new one
    const element = this.markers[space.id]
      ? this.markers[space.id].getElement()
      : document.createElement('div');

    element.innerHTML = space.html;

    if (!this.markers[space.id]) {
      // Need to add new markers to this.markers, to keep track:
      this.markers[space.id] = new mapboxgl.Marker(element)
        .setLngLat([space.lng, space.lat])
        .addTo(this.map);
    }
  }

  removeMarker(key) {
    this.markers[key].remove();
    delete this.markers[key];
  }

  async loadNewMapPosition() {
    document.getElementById('space-listing').innerText = 'Laster...';

    const northWest = this.map.getBounds().getNorthWest();
    const southEast = this.map.getBounds().getSouthEast();
    const fetchSpacesInRectUrl = `/spaces_in_rect?north_west_lat=${northWest.lat}&north_west_lng=${northWest.lng}&south_east_lat=${southEast.lat}&south_east_lng=${southEast.lng}`;
    const spacesInRect = await (await fetch(fetchSpacesInRectUrl)).json();

    // Replace the spaces list with the new view rendered by the server
    document.getElementById('space-listing').innerHTML = spacesInRect.listing;

    const { markers } = spacesInRect;
    // Remove markers that are no longer relevant
    Object.keys(this.markers).forEach((key) => {
      if (markers.find((space) => space.id === key)) return;
      this.removeMarker(key);
    });

    // Add or update the ones we want to show:
    markers.forEach((space) => {
      this.addMarker(space);
    });
  }
}
