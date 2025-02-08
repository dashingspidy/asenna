class Supplier < ApplicationRecord
  belongs_to :brand
  has_many :product_suppliers, dependent: :destroy
  has_many :products, through: :product_suppliers

  validates_presence_of :name, :phone
  validates_uniqueness_of :phone
end
