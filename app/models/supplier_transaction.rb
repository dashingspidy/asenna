class SupplierTransaction < ApplicationRecord
  belongs_to :supplier

  enum :transaction_type, { purchase: "purchase", payment: "payment" }

  validates :transaction_type, :amount, :date, presence: true
end
