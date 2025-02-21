import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.currentRange = "weekly"
    this.updateButtonStates()
  }

  update(event) {
    event.preventDefault()
    const button = event.currentTarget
    const range = button.dataset.chartRange

    this.currentRange = range
    this.updateButtonStates()

    fetch(`/dashboard/sales_chart_data?range=${range}`, {
      headers: {
        "Accept": "application/json",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.json())
    .then(data => {
      const chart = Chartkick.charts["sales_chart"]
      if (chart) {
        chart.updateData(data)
      }
    })
    .catch(error => console.error("Error updating chart:", error))
  }

  updateButtonStates() {
    this.element.querySelectorAll('button').forEach(button => {
      if (button.dataset.chartRange === this.currentRange) {
        button.classList.add('btn-active')
      } else {
        button.classList.remove('btn-active')
      }
    })
  }
}