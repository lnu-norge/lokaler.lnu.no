import mapboxgl from 'mapbox-gl';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [ "facility", "spaceType", "location" ]
  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    navigator.geolocation.getCurrentPosition((position) => {
      this.initializeMap({
        center: [position.coords.longitude, position.coords.latitude],
        zoom: 11,
      });
    }, () => {
      fetch('/rect_for_spaces').then((response) => response.json()).then((rectForSpaces) => {
        const { northEast, southWest } = rectForSpaces;
        this.initializeMap({
          bounds: new mapboxgl.LngLatBounds(
            new mapboxgl.LngLat(southWest.lng, southWest.lat),
            new mapboxgl.LngLat(northEast.lng, northEast.lat),
          ),
        });
      });
    }, { timeout: 60000 });
  }

  submitSearch(event) {
    event.preventDefault();

    this.loadNewMapPosition();
  }

  initializeMap(options) {
    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      ...options,
    });

    this.setupEventCallbacks();

    // Hash for storing markers, based on
    // { spaceId: mapBoxMarker }
    this.markers = {};

    this.loadNewMapPosition();
  }

  setupEventCallbacks() {
    this.loadPositionOn('dragend');
    this.loadPositionOn('zoomend');
    this.loadPositionOn('rotateend');
    this.loadPositionOn('pitchend');
    this.loadPositionOn('boxzoomend');
    this.loadPositionOn('touchend')
  }

  loadPositionOn(event) {
    this.map.on(event, () => {
      this.loadNewMapPosition();
    });
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

  buildSearchURL() {

    // TODO: extract url building to it's own function
    const northWest = this.map.getBounds().getNorthWest();
    const southEast = this.map.getBounds().getSouthEast();

    let facilitiesString = "";

    this.facilityTargets.forEach(t => {
      if(t.checked)
        facilitiesString += `facilities[]=${t.name}&`;
    });

    let spaceTypesString = "";
    this.spaceTypeTargets.forEach(t => {
      if(t.checked)
        spaceTypesString += `space_types[]=${t.name}&`;
    });


    const fetchSpacesInRectUrl = [
      '/spaces_search?',
      `north_west_lat=${northWest.lat}&`,
      `north_west_lng=${northWest.lng}&`,
      `south_east_lat=${southEast.lat}&`,
      `south_east_lng=${southEast.lng}&`,
      `location=${this.locationTarget.value}&`,
      facilitiesString,
      spaceTypesString,
    ].join('');

    return fetchSpacesInRectUrl;
  }

  async loadNewMapPosition() {
    //document.getElementById('space-listing').innerText = 'Laster...';

    const spacesInRect = await (await fetch(this.buildSearchURL())).json();

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
