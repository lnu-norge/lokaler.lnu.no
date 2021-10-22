import mapboxgl from 'mapbox-gl';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [ "facility", "spaceType", "location", "searchBox" ]

  async initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    const position = await this.requestPosition();

    if(position != null) {
      this.initializeMap({
        center: [position.coords.longitude, position.coords.latitude],
        zoom: 11,
      });
    }
    else {
      const {northEast, southWest} = await (await fetch('/rect_for_spaces')).json();
      this.initializeMap({
        bounds: new mapboxgl.LngLatBounds(
          new mapboxgl.LngLat(southWest.lng, southWest.lat),
          new mapboxgl.LngLat(northEast.lng, northEast.lat),
        ),
      });
    }
  }

  toggleSearchBox() {
    this.searchBoxTarget.classList.toggle("hidden");
  }

  requestPosition() {
    var options = {
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

    this.spaceTypeTargets.forEach(spaceType => {
      spaceType.onchange = () => {
        this.loadNewMapPosition();
      };
    });

    this.facilityTargets.forEach(spaceType => {
      spaceType.onchange = () => {
        this.loadNewMapPosition();
      };
    });

    this.locationTarget.onchange = (event) => {
      this.submitSearch(event)
    };
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

  async submitSearch(event) {
    const url =`https://ws.geonorge.no/stedsnavn/v1/sted?sok=${event.target.value}&fuzzy=true`
    const result = await (await fetch(url)).json();

    if(result.navn.length == 0)
      return;

    const location = result.navn[0].geojson.geometry;

    if(location.type == "Point")
      this.map.flyTo({ center: location.coordinates, zoom: 17 });
    else {
      this.map.fitBounds(location.coordinates)
    }
  }

  removeMarker(key) {
    this.markers[key].remove();
    delete this.markers[key];
  }

  buildSearchURL() {
    const northWest = this.map.getBounds().getNorthWest();
    const southEast = this.map.getBounds().getSouthEast();

    const facilitiesString = this.facilityTargets.map(t =>
      t.checked ? `facilities[]=${t.name}&` : ''
    );

    const spaceTypesString = this.spaceTypeTargets.map(t =>
      t.checked ? `space_types[]=${t.name}&` : ''
    );

    const fetchSpacesInRectUrl = [
      '/spaces_search?',
      `north_west_lat=${northWest.lat}&`,
      `north_west_lng=${northWest.lng}&`,
      `south_east_lat=${southEast.lat}&`,
      `south_east_lng=${southEast.lng}&`,
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
