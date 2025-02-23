class Customer < ApplicationRecord
  has_many :sales
  has_many :customer_transactions

  validates :phone, :name, presence: true, uniqueness: true

  def total_due
    customer_transactions.where(transaction_type: "purchase").sum(:amount) -
      customer_transactions.where(transaction_type: "payment").sum(:amount)
  end
end
