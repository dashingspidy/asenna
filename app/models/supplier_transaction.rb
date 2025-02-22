class SupplierTransaction < ApplicationRecord
  belongs_to :supplier, optional: true

  attr_accessor :payment_amount
  enum :transaction_type, { purchase: "purchase", payment: "payment", expense: "expense" }

  validates :transaction_type, :amount, :date, presence: true
end
