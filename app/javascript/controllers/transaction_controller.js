import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaction"
export default class extends Controller {
  static targets = ["paymentAmount", "supplier"]

  togglePaymentAmount(event) {
    if (event.target.value === "purchase") {
      this.paymentAmountTarget.classList.remove("hidden")
      this.supplierTarget.classList.remove("hidden")
    } else if (event.target.value === "payment") { 
      this.supplierTarget.classList.remove("hidden")
      this.paymentAmountTarget.classList.add("hidden")
    } else {
      this.paymentAmountTarget.classList.add("hidden")
      this.supplierTarget.classList.add("hidden")
    }
  }
}
