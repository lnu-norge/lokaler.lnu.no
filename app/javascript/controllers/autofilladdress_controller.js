import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["address", "postNumber", "postAddress", "mapHolder"]

  async connect() {
    this.addressTarget.onchange = () => { this.updateFields() };
    this.postNumberTarget.onchange = () => { this.updateFields() };
    this.postAddressTarget.onchange = () => { this.updateFields() };
  }

  async updateFields() {
    const url = [
      `/address_search?`,
      `address=${this.addressTarget.value}&`,
      `post_number=${this.postNumberTarget.value}&`,
      `post_address=${this.postAddressTarget.value}`].join('');

    const result = await (await fetch(url)).json();

    if (result && result.address) {
      this.addressTarget.value = result.address;
      this.postNumberTarget.value = result.post_number;
      this.postAddressTarget.value = result.post_address;

      // Run form.change, so the form knows about the new data:
      this.addressTarget.form.dispatchEvent(new Event("change"))
    }

    this.mapHolderTarget.innerHTML = result.map_image_html;
  }
}
