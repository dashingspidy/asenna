class Supplier < ApplicationRecord
  belongs_to :brand
  has_many :product_suppliers, dependent: :destroy
  has_many :products, through: :product_suppliers
  has_many :supplier_transactions, dependent: :destroy

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates_presence_of :name, :phone
  validates_uniqueness_of :phone

  def total_due
    supplier_transactions.where(transaction_type: "purchase").sum(:amount) - supplier_transactions.where(transaction_type: "payment").sum(:amount)
  end
end
