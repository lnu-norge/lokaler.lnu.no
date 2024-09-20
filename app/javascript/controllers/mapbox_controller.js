import mapboxgl from 'mapbox-gl';
import { Controller } from "@hotwired/stimulus";
import capsule_html from './search_and_filter/capsule_html';

export default class extends Controller {
  static targets = [
      "form",
      "location",
      "northWestLatInput",
      "northWestLngInput",
      "southEastLatInput",
      "southEastLngInput",
      "searchBox",
      "searchArea"
  ]

  async initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;
    await this.runStoredFilters();
  }

  showSearchBox() {
    this.searchBoxTarget.classList.remove("hidden");
  }

  hideSearchBox() {
    this.searchBoxTarget.classList.add("hidden");
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

    this.loadNewMapPosition();
  }

  disableCapsule(event) {
    let foundFilterToReset = false;

    this.loadNewMapPosition();
    this.updateUrl();
  }

  updateUrl() {
    const selectedLocation = this.selectedLocation();

    this.setOrDeleteToUrl('location_bounds', selectedLocation);
  }

  resetUrlToRootPath() {
    const url = new URL(window.location);
    url.pathname = '/';

    window.history.replaceState(null, null, url);
  }

  setOrDeleteToUrl(key, value) {
    const url = new URL(window.location);

    if (value) {
      url.searchParams.set(key, value);
    }
    else {
      url.searchParams.delete(key);
    }

    window.history.replaceState(null, null, url);
  }

  selectedLocation() {
    return this.map.getBounds().toArray();
  }


  async runStoredFilters() {
    await this.parseUrl()
  }

  async parseUrl() {
    const url = new URL(window.location);
    const north_west_lat = url.searchParams.get('north_west_lat');
    const north_west_lng = url.searchParams.get('north_west_lng');
    const south_east_lat = url.searchParams.get('south_east_lat');
    const south_east_lng = url.searchParams.get('south_east_lng');

    const location_bounds_defined = north_west_lat && north_west_lng && south_east_lat && south_east_lng;

    if (location_bounds_defined) {
      return this.initializeMap({
        bounds: new mapboxgl.LngLatBounds(
          new mapboxgl.LngLat(north_west_lng, north_west_lat),
          new mapboxgl.LngLat(south_east_lng, south_east_lat)
        ),
      });
    }

    const {northEast, southWest} = await (await fetch('/rect_for_spaces')).json();
    this.initializeMap({
      bounds: new mapboxgl.LngLatBounds(
        new mapboxgl.LngLat(southWest.lng, southWest.lat),
        new mapboxgl.LngLat(northEast.lng, northEast.lat),
      ),
    });
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

    this.debounce = (name, time, callback) => {
      this.debounceTimeouts = this.debounceTimeouts || {};

      if (this.debounceTimeouts[name]) {
        clearTimeout(this.debounceTimeouts[name]);
      }
      this.debounceTimeouts[name] = setTimeout(callback, time);
    }

    this.clearDebounce = (name) => {
        if (this.debounceTimeouts &&
            this.debounceTimeouts[name]) {
            clearTimeout(this.debounceTimeouts[name]);
        }
    }

    this.locationTarget.onchange = (event) => {
      this.getSearchCoordinatesFromGeoNorge(event)
    };
  }

  runSearch() {
    this.loadNewMapPosition();
    this.updateUrl();
  }

  loadPositionOn(event) {
    this.map.on(event, () => {
      this.updateUrl();
      this.searchAreaTarget.classList.remove('hidden');
    });
  }

  reloadPosition() {
    this.loadNewMapPosition();
    this.updateUrl();
    this.searchAreaTarget.classList.add('hidden');
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
    const [lng1, lat1] = avgrensningsboks[0];
    const [lng2, lat2] = avgrensningsboks[2];
    return [lng1, lat1, lng2, lat2];
  }

  moveMapToFitNorway() {
    return this.storeBoundsAndMoveMapToFit([4.032154,57.628953,31.497974,71.269784])
  }
  storeBoundsAndMoveMapToFit(bounds) {

    const northWestLng = bounds[0];
    const southEastLat = bounds[1];
    const southEastLng = bounds[2];
    const northWestLat = bounds[3];

    this.northWestLatInputTarget.value = northWestLat;
    this.northWestLngInputTarget.value = northWestLng;
    this.southEastLatInputTarget.value = southEastLat;
    this.southEastLngInputTarget.value = southEastLng;

    this.formTarget.requestSubmit();

    this.map.fitBounds(bounds, {
      padding: 0,
      animate: false
    }, {
      wasZoom: true,
    });
  }

  removeMarker(key) {
    this.markers[key].remove();
    delete this.markers[key];
  }

  buildSearchURL() {
    return [
      '/spaces_search'
    ].join('');
  }


  showErrorInListing(options) {
    const {message, error_html} = options

    document.getElementById('space-listing').innerHTML = `<div class='text-left p-8 bg-lnu-pink/10 rounded-lg text-lnu-pink'>
        <h2 class="text-lg pb-8 font-bold">${message}</h2>
        <p>Fungerer det ikke så vis dette til teknisk ansvarlig:</p>
          <iframe class='w-full h-screen border-8 border-lnu-pink' src='data:text/html;charset=utf-8,${escape(error_html)}' />
    </div>`
  }

  async loadNewMapPosition() {

    return console.log("Turned off map search")

    const searchUrl = this.buildSearchURL()

    const results = await fetch(searchUrl);
    if (!results.ok) {
      const error_html = await results.text();
      return this.showErrorInListing({
        message: "Ooops, noe har gått galt, prøv igjen?",
        error_html: error_html
      });
    }

    const spacesInRect = await results.json();

    const { markers } = spacesInRect;
    // Remove markers that are no longer relevant
    Object.keys(this.markers).forEach((key) => {
      if (markers.find((space) => space.id === key)) return;
      this.removeMarker(key);
    });

    // Add or update the ones we want to show:
    markers.reverse().forEach((space) => {
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
