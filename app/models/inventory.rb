class Inventory < ApplicationRecord
  belongs_to :product
  has_many :stock_transactions, dependent: :destroy

  validates :quantity, numericality: { greater_than: 0 }
end
