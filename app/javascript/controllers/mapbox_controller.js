import mapboxgl from "mapbox-gl"
import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    // TODO: Move this key to an env variable
    mapboxgl.accessToken = 'pk.eyJ1IjoibWF0aGlhczIzNCIsImEiOiJja3R3eHExazYwejRpMzBteGgwamNsa3pqIn0.yQvHP3QMwl7T827tlDS78Q';

    const map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [-74.5, 40],
      zoom: 9
    });
  }
}
