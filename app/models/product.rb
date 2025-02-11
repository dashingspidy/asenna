class Product < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :product_suppliers, dependent: :destroy
  has_many :suppliers, through: :product_suppliers
  belongs_to :brand

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
