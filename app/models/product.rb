class Product < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :product_suppliers, dependent: :destroy
  has_many :suppliers, through: :product_suppliers
  has_many :sale_items
  belongs_to :brand

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :most_sold, -> {
    joins(:sale_items)
      .select("products.*, SUM(sale_items.quantity) AS total_sold")
      .group("products.id")
      .order("total_sold DESC")
      .limit(10)
  }

  scope :search_by_name, ->(query) {
    where("LOWER(products.name) LIKE ?", "%#{query.downcase}%").distinct if query.present?
  }

  scope :top_selling, ->(limit = 6) {
    joins(:sale_items, :brand)
      .group("products.name, brands.name")
      .order(Arel.sql("SUM(sale_items.quantity) DESC"))
      .limit(limit)
  }

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == :inventory_form
      [ "name" ]
    else
      [ "brand_id", "created_at", "description", "id", "name", "price", "updated_at" ]
    end
  end

  def reduce_stock(quantity)
    inventory = Inventory.find_by(product_id: id)
    return unless inventory

    inventory.quantity -= quantity
    inventory.save
  end
end
