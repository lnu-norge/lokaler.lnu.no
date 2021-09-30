import mapboxgl from "mapbox-gl"
import { Controller } from "stimulus"

export default class extends Controller {
  initialize() {
    mapboxgl.accessToken = this.element.dataset.apiKey;

    this.map = new mapboxgl.Map({
      container: 'map-frame',
      style: 'mapbox://styles/mapbox/streets-v11',
      center: [10.925860, 59.223840],
      zoom: 11
    });

    this.map.on('moveend', () => {
      this.loadMarkers()
    });

    // Hash for storing markers, based on
    // { spaceId: mapBoxMarker }
    this.markers = {}

    this.loadMarkers()
  }

  addMarker(space) {
    // If marker is already added, then just update that element, otherwise, create a new one
    const element = this.markers[space.id]
        ? this.markers[space.id].getElement()
        : document.createElement('a')

    element.href = space.url
    element.className = "flex unstyled-link items-center gap-2 text-base rounded-full py-1 px-4 border border-gray-100 hover:border-pink-500 bg-white shadow-lg cursor-pointer"
    element.innerHTML = /*html*/`
        <span class="font-bold">${space.title}</span>
        <span class="inline-flex items-center gap-0.5 ${space.starRating ? 'text-pink-500' : 'text-gray-300'}">
            ${space.starRating || "-"}
            <svg width="1em" height="1em" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
                 <path class="fill-current" d="M10.62 1.30882C10.8297 0.885139 11.1718 0.885139 11.3806 1.30882L14.0188 6.65504C14.2285 7.07871 14.782 7.48175 15.2495 7.54878L21.1499 8.40815C21.6174 8.47604 21.7239 8.80175 21.3853 9.13175L17.116 13.2928C16.7774 13.6228 16.566 14.2742 16.6459 14.74L17.6531 20.6164C17.733 21.0822 17.4555 21.2833 17.0378 21.0633L11.7604 18.2876C11.3419 18.0676 10.657 18.0676 10.2393 18.2876L4.96197 21.0615C4.54346 21.2815 4.26673 21.0804 4.34665 20.6147L5.35469 14.7383C5.43461 14.2725 5.22321 13.6211 4.88462 13.2911L0.615297 9.12999C0.276695 8.79999 0.382405 8.47514 0.850763 8.40639L6.75116 7.54702C7.21866 7.47914 7.77295 7.07609 7.9818 6.65328L10.62 1.30882Z" />
            </svg>
        </span>
    `

    if (!this.markers[space.id]) {
      // Marker not added, so we need to add it:
      this.markers[space.id] = new mapboxgl.Marker(element)
          .setLngLat([space.lng, space.lat])
          .addTo(this.map)
    }
  }

  removeMarker(key) {
    this.markers[key].remove()
    delete this.markers[key]
  }

  async loadMarkers() {

    const northWest = this.map.getBounds().getNorthWest()
    const southEast = this.map.getBounds().getSouthEast()
    const fetchSpacesInRectUrl = `/spaces_in_rect?north_west_lat=${northWest.lat}&north_west_lng=${northWest.lng}&south_east_lat=${southEast.lat}&south_east_lng=${southEast.lng}`
    const spacesInRect = await (await fetch(fetchSpacesInRectUrl)).json()

    // Remove markers that are no longer relevant
    Object.keys(this.markers).forEach(key => {
      if (spacesInRect.find( space => space.id === key)) return;
      this.removeMarker(key)
    })

    // Add or update the ones we want to show:
    spacesInRect.forEach(space => {
      this.addMarker(space)
    });
  }
}
