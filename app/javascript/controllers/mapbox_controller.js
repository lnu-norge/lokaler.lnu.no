import mapboxgl from 'mapbox-gl';
import { Controller } from "@hotwired/stimulus";
import capsule_html from './search_and_filter/capsule_html';

export default class extends Controller {
  static targets = [
      "facility",
      "spaceType",
      "location",
      "searchBox",
      "title",
      "form",
      "filterCapsules",
      "searchArea"
  ]

  async initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    await this.parseUrl();

    // When you hit the back button, the page will reload.
    // Even if the history was set with replaceState or pushState.
    window.onpopstate = () => {
      location.reload();
    };
  }

  showSearchBox() {
    this.searchBoxTarget.classList.remove("hidden");
    let searchField = document.getElementById("locationInput-ts-control");
    searchField.focus();
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
      ...options,
    });

    this.setupEventCallbacks();

    // Hash for storing markers, based on
    // { spaceId: mapBoxMarker }
    this.markers = {};

    this.loadNewMapPosition();
  }

  updateFilterCapsules() {
    const titleCapsule = this.titleTarget.value ? capsule_html(`"${this.titleTarget.value}"`) : '';

    const facilityCapsules = this.facilityTargets.map(t =>
      t.checked ? capsule_html(t.id) : ''
    ).join('');

    const spaceTypeCapsules = this.spaceTypeTargets.map(t =>
      t.checked ? capsule_html(t.id) : ''
    ).join('');

    this.filterCapsulesTarget.innerHTML = titleCapsule + facilityCapsules + spaceTypeCapsules;
  }

  disableCapsule(event) {
    let foundFilterToReset = false;

    this.facilityTargets.forEach(t => {
      if (t.id === event.target.innerText) {
        t.checked = false;
        foundFilterToReset = true;
      }
    });

    this.spaceTypeTargets.forEach(t => {
      if (t.id === event.target.innerText) {
        t.checked = false;
        foundFilterToReset = true;
      }
    });

    if (!foundFilterToReset)  {
      // Then it's the title serach capsule
      this.titleTarget.value = '';
    }

    this.updateFilterCapsules();
    this.loadNewMapPosition();
    this.updateUrl();
  }

  updateUrl() {
    const url = new URL(window.location);

    const selectedFacilities = this.selectedFacilities();
    const selectedSpaceTypes = this.selectedSpaceTypes();
    const selectedLocation = this.selectedLocation();
    const searchForTitle = this.titleTarget.value;

    this.setOrDeleteToUrl('selectedFacilities', selectedFacilities);
    this.setOrDeleteToUrl('selectedSpaceTypes', selectedSpaceTypes);
    this.setOrDeleteToUrl('selectedLocation', selectedLocation);
    this.setOrDeleteToUrl('searchForTitle', searchForTitle);
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

  selectedFacilities() {
    return this.facilityTargets.filter(t => t.checked).map(t => t.id).join(',');
  }

  selectedSpaceTypes() {
    return this.spaceTypeTargets.filter(t => t.checked).map(t => t.id).join(',');
  }

  selectedLocation() {
    return [this.map.getCenter().lat.toFixed(4), this.map.getCenter().lng.toFixed(4), this.map.getZoom()].join(',');
  }

  async parseUrl() {
    const url = new URL(window.location);
    const selectedFacilities = url.searchParams.get('selectedFacilities');
    const selectedSpaceTypes = url.searchParams.get('selectedSpaceTypes');
    const selectedLocation = url.searchParams.get('selectedLocation');
    const searchForTitle = url.searchParams.get('searchForTitle');

    this.parseSelectedFacilities(selectedFacilities);
    this.parseSelectedSpaceTypes(selectedSpaceTypes);
    this.parseSearchForTitle(searchForTitle);

    this.updateFilterCapsules();

    if (selectedLocation) {
      this.parseSelectedLocation(selectedLocation);
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

  parseSearchForTitle(searchForTitle) {
    if(searchForTitle) {
      this.titleTarget.value = searchForTitle;
    } else {
      this.titleTarget.value = '';
    }
  }
  parseSelectedFacilities(selectedFacilities) {
    if(!selectedFacilities) return;

    selectedFacilities.split(',').forEach(facility => {
      this.facilityTargets.forEach(t => {
        if (t.id === facility) {
          t.checked = true;
        }
      });
    });
  }

  parseSelectedSpaceTypes(selectedSpaceTypes) {
    if(!selectedSpaceTypes) return;

    selectedSpaceTypes.split(',').forEach(spaceType => {
      this.spaceTypeTargets.forEach(t => {
        if (t.id === spaceType) {
          t.checked = true;
        }
      });
    });
  }

  parseSelectedLocation(selectedLocation) {
    const [lat, lng, zoom] = selectedLocation.split(',');
    this.initializeMap({
      center: [lng, lat],
      zoom: zoom,
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

    this.titleTarget.oninput = () => {
      this.debounce(
          "titleSearch",
          500,
          () => this.runSearch()
      );
    }

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

    this.spaceTypeTargets.forEach(spaceType => {
      spaceType.onchange = () => {
        this.runSearch()
      };
    });

    this.facilityTargets.forEach(spaceType => {
      spaceType.onchange = () => {
        this.runSearch()
      };
    });

    this.locationTarget.onchange = (event) => {
      this.submitSearch(event)
    };

    this.formTarget.onsubmit = (event) => {
      // To stop the form from submitting, as that currently does nothing but refresh the page.
      event.preventDefault()
      this.clearDebounce("titleSearch")
      this.submitSearch(event)
      this.hideSearchBox()
    };
  }

  runSearch() {
    this.updateFilterCapsules();
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

  async submitSearch(event) {
    const url =`https://ws.geonorge.no/stedsnavn/v1/sted?sok=${event.target.value}&fuzzy=true`
    const result = await (await fetch(url)).json();

    if(result.navn.length === 0)
      return;

    const place = result.navn[0]
    this.flyToGeoNorgeLocation(place)
  }

  removeMarker(key) {
    this.markers[key].remove();
    delete this.markers[key];
  }

  buildSearchURL() {
    const northWest = this.map.getBounds().getNorthWest();
    const southEast = this.map.getBounds().getSouthEast();

    const facilitiesString = this.facilityTargets.map(t =>
      t.checked ? `facilities[]=${encodeURIComponent(t.name)}&` : ''
    ).join('');

    const spaceTypesString = this.spaceTypeTargets.map(t =>
      t.checked ? `space_types[]=${encodeURIComponent(t.name)}&` : ''
    ).join('');

    const title = this.titleTarget.value;

    return [
      '/spaces_search?',
      `north_west_lat=${northWest.lat}&`,
      `north_west_lng=${northWest.lng}&`,
      `south_east_lat=${southEast.lat}&`,
      `south_east_lng=${southEast.lng}&`,
      `search_for_title=${title}&`,
      facilitiesString,
      spaceTypesString,
    ].join('');
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
    markers.reverse().forEach((space) => {
      this.addMarker(space);
    });
  }

  flyToGeoNorgeLocation(place) {
    const location = place.geojson.geometry;

    if (location.type === "Point") {
      this.flyToPoint(location.coordinates)
    }

    if (location.type === "MultiPoint") {
      // MultiPoints can have arbitrary amounts of points, and so needs to be fit
      // as described here:  https://docs.mapbox.com/mapbox-gl-js/example/zoomto-linestring/
      const bounds = new mapboxgl.LngLatBounds(
          location.coordinates[0],
          location.coordinates[0]
      );
      for (const coord of location.coordinates) {
        bounds.extend(coord);
      }
      return this.map.fitBounds(bounds, {
        padding: 100
      }, { wasZoom: true });
    }

    // Unsure about location type given, use the center given by representasjonspunkt instead
    const point = [
      place.representasjonspunkt.øst,
      place.representasjonspunkt.nord
    ];
    return this.flyToPoint(point);
  }

  flyToPoint(point) {
    this.map.jumpTo({ center: point, zoom: 12 }, { wasZoom: true });
  }

  async enableLocationService() {
    const position = await this.requestPosition();

    if(position != null) {
      this.flyToPoint([position.coords.longitude, position.coords.latitude]);
    }
    else {
      alert('Kunne ikke hente lokasjon. Sjekk at lokasjon er skrudd på')
    }
  }
}
