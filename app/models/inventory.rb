class Inventory < ApplicationRecord
  belongs_to :product
  has_many :stock_transactions, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
