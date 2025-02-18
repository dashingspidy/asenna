class Inventory < ApplicationRecord
  belongs_to :product
  has_many :stock_transactions, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :low_stock, ->(threshold = 10) { where("quantity < ?", threshold) }
end
