class Product < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :product_suppliers, dependent: :destroy
  has_many :suppliers, through: :product_suppliers
  belongs_to :brand

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }, allow_nil: true
end
