import mapboxgl from 'mapbox-gl';
import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = [
      "form",
      "northWestLatInput",
      "northWestLngInput",
      "southEastLatInput",
      "southEastLngInput",
      "searchThisArea",
      "markerContainer",
      "mapContainer"
  ]

  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;
    this.markersFromSearchResults = {};
    this.hoveringMarker = null
    this.map = false;
    this.resizeObserver = false;
    this.hoveredSpaceId = null;
  }

  connect() {
    this.setup();
  }

  markerContainerTargetConnected() {
    if (!this.map) {
      return;
    }

    this.loadMarkersFromSearchResults();
  }

  async setup() {
    console.log("Setting up mapbox, this should only happen once")
    await this.runStoredFilters();
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

  async initializeMap(options) {
    await this.mapContainerIsLoaded();
    if (!this.map) {
      this.map = new mapboxgl.Map({
        container: 'map-frame',
        style: 'mapbox://styles/mapbox/streets-v11',
        trackResize: true,
        pitchWithRotate: false,
        dragRotate: false,
        touchRotate: false,
        touchPitch: false,
        keyboardRotate: false,
        ...options,
      });
      this.setupEventCallbacks();
    } else {
      console.log("Map already exists");
      this.map.fitBounds(options.bounds)
    }

    this.setUpResizeObserver();

    this.map.on("load", () => {
      this.markersFromSearchResults = {};
      this.loadMarkersFromSearchResults();

      this.add_selected_geo_area_layer()

      this.add_spaces_vector_layer()
      this.add_hover_effect_on_spaces_vector_layer()

      this.reload_layers_when_filter_changes()
    })
  }

  setUpResizeObserver() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }

    this.resizeObserver = new ResizeObserver(() => {
      this.map.resize();
    });

    this.resizeObserver.observe(document.getElementById('map-frame'));
  }

  mapContainerIsLoaded() {
    return new Promise((resolve) => {
      if (this.hasMapContainerTarget) {
        resolve()
      } else {
        const observer = new MutationObserver((mutations, obs) => {
          if (this.hasMapContainerTarget) {
            obs.disconnect()
            resolve()
          }
        })

        observer.observe(this.element, {
          childList: true,
          subtree: true
        })
      }
    })
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
      northWestLat: url.searchParams.get('north_west_lat') || this.northWestLatInputTarget.value,
      northWestLng: url.searchParams.get('north_west_lng') || this.northWestLngInputTarget.value,
      southEastLat: url.searchParams.get('south_east_lat') || this.southEastLatInputTarget.value,
      southEastLng: url.searchParams.get('south_east_lng') || this.southEastLngInputTarget.value
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
  }
  loadPositionOn(event) {
    this.map.on(event, () => {
      this.showSearchThisAreaBox();
      this.deboounceReloadMap(500);
    });
  }

  reloadPosition() {
    const bounds = this.currentBounds();
    this.submitNewBounds(bounds);
    this.hideSearchThisAreaBox();
  }

  get autoFilteringByMapBounds() {
    return document.getElementById("filter_by_map_bounds").checked;
  }

  showSearchThisAreaBox() {
    if (this.autoFilteringByMapBounds) {
      return;
    }

    this.searchThisAreaTarget.classList.remove('hidden');
  }

  hideSearchThisAreaBox() {
    this.searchThisAreaTarget.classList.add('hidden');
  }

  deboounceReloadMap(time) {
    this.debounce("reloadMap", async () => {
      await this.reloadPosition();
    }, time);
  }

  debounce(timeoutName, func, time) {
    if (this[timeoutName]) {
      clearTimeout(this[timeoutName]);
    }
    this[timeoutName] = setTimeout(() => {
      this[timeoutName] = false;
      func();
    }, time);
  }


  addSearchResultMarker(space) {
    // If marker is already added, then just update that element, otherwise, create a new one
    const element = this.markersFromSearchResults[space.id]
      ? this.markersFromSearchResults[space.id].getElement()
      : document.createElement('div');

    element.innerHTML = space.html;

    if (!this.markersFromSearchResults[space.id]) {
      // Need to add new markers to this.markers, to keep track:
      this.markersFromSearchResults[space.id] = new mapboxgl.Marker(element)
        .setLngLat([space.lng, space.lat])
        .addTo(this.map);
    }
  }

  removeSearchResultMarker(key) {
    this.markersFromSearchResults[key].remove();
    delete this.markersFromSearchResults[key];
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

  mapboxglBoundsToBoundingBox(mapboxBounds) {
    return {
      northWestLat: mapboxBounds.getNorthWest().lat,
      northWestLng: mapboxBounds.getNorthWest().lng,
      southEastLat: mapboxBounds.getSouthEast().lat,
      southEastLng: mapboxBounds.getSouthEast().lng
    }
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

  async loadMarkersFromSearchResults() {
    const new_markers = JSON.parse(this.markerContainerTarget.dataset.markers) || [];

    // Remove old markers
    Object.keys(this.markersFromSearchResults).forEach((key) => {
      this.removeSearchResultMarker(key);
    });

    // Add or update the ones we want to show:
    new_markers.reverse().forEach((space) => {
      this.addSearchResultMarker(space);
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


  reload_layers_when_filter_changes() {
    this.formTarget.onchange = (e) => {
      if (e.target.name === 'north_west_lat' || e.target.name === 'north_west_lng' || e.target.name === 'south_east_lat' || e.target.name === 'south_east_lng') {
        return;
      }

      this.debounce("reload_layers", () => {
        this.add_selected_geo_area_layer();
        this.add_spaces_vector_layer();
      }, 100);
    }
  }

  async add_selected_geo_area_layer() {
    const formData = new FormData(this.formTarget);
    const filter_params = new URLSearchParams(formData).toString();
    const selected_geo_areas = formData.getAll('fylker[]').concat(formData.getAll('kommuner[]'));
    this.selected_geo_areas_string = JSON.stringify(formData.getAll('fylker[]').concat(formData.getAll('kommuner[]')));

    if (selected_geo_areas.length === 0 && this.selectedGeoAreaHasChanged()) {
      return this.moveMapToFitNorway();
    }

    this.selected_geo_areas_geo_json = await fetch(`${window.location.origin}/lokaler/map_selected_geo_area?${filter_params}`).then(response => response.json());

    if (this.map.getLayer('selected_geo_area_layer')) {
      this.map.removeLayer('selected_geo_area_layer');
    }
    if (this.map.getSource('selected_geo_area_source')) {
      this.map.removeSource('selected_geo_area_source');
    }

    this.map.addSource('selected_geo_area_source', {
      type: 'geojson',
      data: this.selected_geo_areas_geo_json
    });

    this.map.addLayer({
      id: 'selected_geo_area_layer',
      type: 'fill',
      source: 'selected_geo_area_source',
      paint: {
        'fill-color': '#C40066',
        'fill-opacity': 0.1
      }
    });

    this.map.on('sourcedata', this.fitMapToSelectedGeoArea.bind(this));
  }

  selectedGeoAreaHasChanged() {
    return !!this.selected_geo_areas_string && !!this.previously_selected_geo_areas_string && this.selected_geo_areas_string === this.previously_selected_geo_areas_string;
  }

  fitMapToSelectedGeoArea(e) {
    if (e.sourceId !== 'selected_geo_area_source' || !e.isSourceLoaded) {
      return;
    }

    if (this.selectedGeoAreaHasChanged()) {
      return;
    }

    const features = this.selected_geo_areas_geo_json.features;
    if (!features || features.length === 0) {
      return;
    }

    this.previously_selected_geo_areas_string = `${this.selected_geo_areas_string}`;


    // Get the bounds of the source data
    let bounds = new mapboxgl.LngLatBounds();

    features.forEach(function(feature) {
      switch (feature.geometry.type) {
        case 'Point':
          bounds.extend(feature.geometry.coordinates);
          break;
        case 'LineString':
          feature.geometry.coordinates.forEach(function(coord) {
            bounds.extend(coord);
          });
          break;
        case 'Polygon':
          feature.geometry.coordinates[0].forEach(function(coord) {
            bounds.extend(coord);
          });
          break;
        case 'MultiPolygon':
          feature.geometry.coordinates.forEach(function(polygon) {
            polygon[0].forEach(function(coord) {
              bounds.extend(coord);
            });
          });
          break;
        default:
          console.warn('Unsupported geometry type:', feature.geometry.type);
      }
    });

    const formattedBounds = this.mapboxglBoundsToBoundingBox(bounds);

    // Fit the map to the bounds
    this.storeBoundsAndMoveMapToFit(formattedBounds);

  }



  add_spaces_vector_layer() {
    const formData = new FormData(this.formTarget);
    const filter_params = new URLSearchParams(formData).toString();

    if (this.map.getLayer('spaces_vector_layer')) {
      this.map.removeLayer('spaces_vector_layer');
    }
    if (this.map.getSource('spaces_vector_source')) {
      this.map.removeSource('spaces_vector_source');
    }

    this.map.addSource('spaces_vector_source', {
      type: 'vector',
      tiles: [window.location.origin + '/lokaler/mapbox_vector_tiles/{z}/{x}/{y}.mvt?' + filter_params],
      promoteId: 'id'
    });

    this.map.addLayer({
      id: 'spaces_vector_layer',
      type: 'circle',
      source: 'spaces_vector_source',
      'source-layer': 'spaces',
      paint: {
        'circle-color': [
          'case',
          ['boolean', ['feature-state', 'hover'], false],
          '#C40066',
          '#FFF'
        ],
        'circle-radius': 5,
        'circle-stroke-width': 1,
        'circle-stroke-color': '#C40066'
      }
    });
  }

  loadHoverMarkerForSpaceId(spaceId) {
    Rails.ajax({
      url: `/lokaler/${spaceId}/map_marker`,
      type: "GET",
      dataType: "json",
      success: (data) => {
        this.setHoverMarker(data);
      },
      error: (error) => {
        console.error('Error:', error)
      }
    })
  }

  setHoverMarker(spaceData) {
    console.log("Setting hover marker")
    // If a marker is already added, then just update that element, otherwise, create a new one
    const html_element = this.hoveringMarker
      ? this.hoveringMarker.getElement()
      : document.createElement('div');

    html_element.innerHTML = spaceData.html;

    this.hoveringMarker = this.hoveringMarker ? this.hoveringMarker : new mapboxgl.Marker(html_element).setLngLat([spaceData.lng, spaceData.lat]).addTo(this.map)

    this.hoveringMarker.setLngLat([spaceData.lng, spaceData.lat])

  }

  removeCurrentHoverMarker(spaceId) {
    this.hoveringMarker?.remove();
    this.hoveringMarker = null;
  }

  add_hover_effect_on_spaces_vector_layer() {
    this.map.on('mouseenter', 'spaces_vector_layer', (e) => {
      if (e.features.length > 0) {
        // If the space is already hovered, then do nothing:
        if (this.hoveredSpaceId === e.features[0].id) {
          return;
        }
        // If the space already has a marker from search results, then do nothing:
        if (this.markersFromSearchResults[e.features[0].id]) {
          return;
        }
        // Else, remove the current hover marker, and load the new one:
        this.removeCurrentHoverMarker();
        this.hoveredSpaceId = e.features[0].id;
        this.loadHoverMarkerForSpaceId(this.hoveredSpaceId);
      }
    });
  }
}
