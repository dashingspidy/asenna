import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hiddenInput", "suggestions"]

  connect() {
    this.hiddenClass = "hidden"
    this.setupClickOutsideListener()
  }

  search() {
    const query = this.inputTarget.value
    if (query.length < 2) {
      this.suggestionsTarget.classList.add(this.hiddenClass)
      return
    }
    this.performSearch(query) 
  }

  async performSearch(query) {
    try {
      const response = await fetch(`/products/search?q=${encodeURIComponent(query)}`)
      const data = await response.json()
      
      this.showSuggestions(data) 
    } catch (error) {
      console.error("Error fetching suggestions:", error)
    }
  }

  showSuggestions(products) {
    if (products.length === 0) {
      this.suggestionsTarget.classList.add(this.hiddenClass)
      return
    }

    this.suggestionsTarget.innerHTML = products.map(product => `
      <div class="suggestion-item p-2 hover:bg-gray-100 cursor-pointer"
           data-action="click->product-selector#selectProduct"
           data-product-id="${product.id}"
           data-product-name="${product.name}">
        <div class="font-medium">${product.name}</div>
        <div class="text-sm text-gray-600">${product.brand}</div>
      </div>
    `).join('')

    this.suggestionsTarget.classList.remove(this.hiddenClass)
  }

  selectProduct(event) {
    const { productId, productName } = event.currentTarget.dataset
    this.hiddenInputTarget.value = productId
    this.inputTarget.value = productName
    this.suggestionsTarget.classList.add(this.hiddenClass)
  }

  setupClickOutsideListener() {
    document.addEventListener('click', (event) => {
      if (!this.element.contains(event.target)) {
        this.suggestionsTarget.classList.add(this.hiddenClass)
      }
    })
  }
}
