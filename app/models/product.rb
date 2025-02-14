class Product < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :product_suppliers, dependent: :destroy
  has_many :suppliers, through: :product_suppliers
  has_many :sale_items
  belongs_to :brand

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  def reduce_stock(quantity)
    inventory = Inventory.find_by(product_id: id)
    return unless inventory

    inventory.quantity -= quantity
    inventory.save
  end
end
