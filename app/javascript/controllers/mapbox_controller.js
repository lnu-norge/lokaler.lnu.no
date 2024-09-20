import mapboxgl from 'mapbox-gl';
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
      "form",
      "location",
      "northWestLatInput",
      "northWestLngInput",
      "southEastLatInput",
      "southEastLngInput",
      "searchThisArea",
      "markerContainer"
  ]

  async initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;
    await this.runStoredFilters();
  }

  markerContainerTargetConnected() {
    if (!this.map) {
      return;
    }

    this.loadMarkers();
  }


  requestPosition() {
    const options = {
      enableHighAccuracy: true,
      timeout:    5000,   // time in millis when error callback will be invoked
      maximumAge: 0,      // max cached age of gps data, also in millis
    };

    return new Promise((resolve) => {
      navigator.geolocation.getCurrentPosition(
        pos => { resolve(pos); },
        _ => { resolve(null); },
        options);
    });
  }

  initializeMap(options) {
    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      trackResize: true,
      ...options,
    });

    // Set up a resize observer as well
    const resizeObserver = new ResizeObserver(() => {
      this.map.resize();
    });
    resizeObserver.observe(document.getElementById('map-frame'));

    this.setupEventCallbacks();

    // Hash for storing markers, based on
    // { spaceId: mapBoxMarker }
    this.markers = {};

    this.loadMarkers();
  }

  currentBounds() {
    return {
      northWestLat: this.map.getBounds().getNorthWest().lat,
      northWestLng: this.map.getBounds().getNorthWest().lng,
      southEastLat: this.map.getBounds().getSouthEast().lat,
      southEastLng: this.map.getBounds().getSouthEast().lng
    }
  }


  async runStoredFilters() {
    await this.parseUrl()
  }

  async parseUrl() {
    const url = new URL(window.location);

    const bounds = {
      northWestLat: url.searchParams.get('north_west_lat'),
      northWestLng: url.searchParams.get('north_west_lng'),
      southEastLat: url.searchParams.get('south_east_lat'),
      southEastLng: url.searchParams.get('south_east_lng')
    }

    const location_bounds_defined = !!bounds.northWestLat && !!bounds.northWestLng && !!bounds.southEastLat && !!bounds.southEastLng;

    if (location_bounds_defined) {
      return this.initializeMap({
        bounds: this.boundsToMapBoxBounds(bounds)
      });
    }

    this.initializeMap({
      bounds: this.boundsToMapBoxBounds(this.BOUNDS_OF_NORWAY)
    });
  }

  boundsToMapBoxBounds(bounds) {
    const {northWestLat, northWestLng, southEastLat, southEastLng} = bounds;
    if (!northWestLat) {
      debugger
    }
    return new mapboxgl.LngLatBounds(
      new mapboxgl.LngLat(northWestLng, northWestLat),
      new mapboxgl.LngLat(southEastLng, southEastLat)
    );
  }

  setupEventCallbacks() {
    this.loadPositionOn('dragend');
    this.loadPositionOn('zoomend');
    this.loadPositionOn('rotateend');
    this.loadPositionOn('pitchend');
    this.loadPositionOn('boxzoomend');
    this.loadPositionOn('touchend')

    this.map.on('moveend', (obj) => {
      if (obj.wasZoom) {
        this.reloadPosition();
      }
    });

    this.locationTarget.onchange = (event) => {
      this.getSearchCoordinatesFromGeoNorge(event)
    };
  }
  loadPositionOn(event) {
    this.map.on(event, () => {
      this.searchThisAreaTarget.classList.remove('hidden');
    });
  }

  reloadPosition() {
    const bounds = this.currentBounds();
    this.submitNewBounds(bounds);
    this.searchThisAreaTarget.classList.add('hidden');
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

  async getSearchCoordinatesFromGeoNorge(event) {

    const url = this.getUrlForGeoNorgeLocation(event);

    if (!url) {
      return this.moveMapToFitNorway();
    }

    const result = await (await fetch(url)).json();
    this.moveMapToGeoNorgeLocation(result);
  }

  getUrlForGeoNorgeLocation(event) {
    const fylkesnummer = event.target.value.split('fylke-')[1];
    const kommunenummer = event.target.value.split('kommune-')[1];

    if (kommunenummer) {
      return `https://ws.geonorge.no/kommuneinfo/v1/kommuner/${kommunenummer}`;
    }

    if (fylkesnummer) {
      return `https://ws.geonorge.no/kommuneinfo/v1/fylker/${fylkesnummer}`;
    }

   // Else return the whole country
   return null
  }


  moveMapToGeoNorgeLocation(result) {

    const avgrensningsboks = result?.avgrensningsboks?.coordinates?.[0]
    if (!avgrensningsboks) {
      return this.moveMapToFitNorway();
    }

    return this.storeBoundsAndMoveMapToFit(this.geoNorgeAvgrensingsBoksToBoundingBox(avgrensningsboks));
  }

  geoNorgeAvgrensingsBoksToBoundingBox = (avgrensningsboks) => {
    const [northWestLng, northWestLat] = avgrensningsboks[1];
    const [southEastLng, southEastLat] = avgrensningsboks[3];
    return {
      northWestLat,
      northWestLng,
      southEastLat,
      southEastLng
    };
  }

  BOUNDS_OF_NORWAY = {
    northWestLat: 71.51756773,
    northWestLng: 3.559116286,
    southEastLat: 57.44508079,
    southEastLng: 31.29341841
  }

  moveMapToFitNorway() {
    return this.storeBoundsAndMoveMapToFit(this.BOUNDS_OF_NORWAY);
  }

  storeBounds(bounds) {
    this.northWestLatInputTarget.value = bounds.northWestLat;
    this.northWestLngInputTarget.value = bounds.northWestLng;
    this.southEastLatInputTarget.value = bounds.southEastLat;
    this.southEastLngInputTarget.value = bounds.southEastLng;
  }

  submitNewBounds(bounds) {
    this.storeBounds(bounds);
    this.formTarget.requestSubmit();
  }

  storeBoundsAndMoveMapToFit(bounds) {

    this.submitNewBounds(bounds);

    this.map.fitBounds([
      bounds.northWestLng, bounds.northWestLat,
      bounds.southEastLng, bounds.southEastLat
    ], {
      padding: 50,
      animate: false
    }, {
      wasZoom: true,
    });
  }

  removeMarker(key) {
    this.markers[key].remove();
    delete this.markers[key];
  }

  showErrorInListing(options) {
    const {message, error_html} = options

    document.getElementById('space-listing').innerHTML = `<div class='text-left p-8 bg-lnu-pink/10 rounded-lg text-lnu-pink'>
        <h2 class="text-lg pb-8 font-bold">${message}</h2>
        <p>Fungerer det ikke så vis dette til teknisk ansvarlig:</p>
          <iframe class='w-full h-screen border-8 border-lnu-pink' src='data:text/html;charset=utf-8,${escape(error_html)}' />
    </div>`
  }

  async loadMarkers() {

    const new_markers = JSON.parse(this.markerContainerTarget.dataset.markers) || [];

      // Remove markers that are no longer relevant
    Object.keys(this.markers).forEach((key) => {
      if (new_markers.find((space) => space.id === key)) return;
      this.removeMarker(key);
    });

    // Add or update the ones we want to show:
    new_markers.reverse().forEach((space) => {
      this.addMarker(space);
    });
  }

  moveMapTo(point) {
    this.map.jumpTo({ center: point, zoom: 12 }, { wasZoom: true });
  }

  async enableLocationService() {
    const position = await this.requestPosition();

    if(position != null) {
      this.moveMapTo([position.coords.longitude, position.coords.latitude]);
    }
    else {
      alert('Kunne ikke hente lokasjon. Sjekk at lokasjon er skrudd på')
    }
  }
}
