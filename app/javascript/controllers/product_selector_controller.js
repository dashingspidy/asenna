import { Controller } from "@hotwired/stimulus"
import SlimSelect from 'slim-select'

// Connects to data-controller="product-selector"
export default class extends Controller {
  connect() {
    this.select = new SlimSelect({
      select: this.element,
      settings: {
        showSearch: true,
        placeholderText: 'Select product'
      }
    })
  }
}
