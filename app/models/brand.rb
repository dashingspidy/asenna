class Brand < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :suppliers, dependent: :destroy

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates :name, presence: true, uniqueness: true

  scope :top_selling, ->(limit = 5) {
    total_sales = SaleItem.sum(:quantity)

    joins(products: :sale_items)
      .group("brands.name")
      .order("SUM(sale_items.quantity) DESC")
      .limit(limit)
      .sum("sale_items.quantity")
      .transform_values { |qty| total_sales.zero? ? 0 : (qty.to_f / total_sales * 100).round(2) }
  }
end
