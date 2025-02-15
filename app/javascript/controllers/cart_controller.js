import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cart"
export default class extends Controller {
  submitForm(event) {
    event.target.form.requestSubmit()
  }
}
