class Supplier < ApplicationRecord
  belongs_to :brand
  has_many :product_suppliers, dependent: :destroy
  has_many :products, through: :product_suppliers
  has_many :supplier_transactions, dependent: :destroy

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates_presence_of :name, :phone
  validates_uniqueness_of :phone

  scope :total_debt, -> {
    joins(:supplier_transactions)
      .where(supplier_transactions: { transaction_type: "purchase" })
      .group(:id)
      .sum("supplier_transactions.amount")
  }

  scope :total_payments, -> {
    joins(:supplier_transactions)
      .where(supplier_transactions: { transaction_type: "payment" })
      .group(:id)
      .sum("supplier_transactions.amount")
  }

  def self.supplier_balance
    debts = total_debt
    payments = total_payments

    debts.transform_values { |purchase| purchase - payments.fetch(purchase, 0) }
  end

  def total_due
    supplier_transactions.where(transaction_type: "purchase").sum(:amount) - supplier_transactions.where(transaction_type: "payment").sum(:amount)
  end
end
