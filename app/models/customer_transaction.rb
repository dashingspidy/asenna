class CustomerTransaction < ApplicationRecord
  belongs_to :customer

  enum :transaction_type, { purchase: "purchase", payment: "payment" }
end
