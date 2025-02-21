class Supplier < ApplicationRecord
  belongs_to :brand
  has_many :product_suppliers, dependent: :destroy
  has_many :products, through: :product_suppliers
  has_many :supplier_transactions, dependent: :destroy

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates_presence_of :name, :phone
  validates_uniqueness_of :phone

  scope :debt_per_supplier, -> {
    joins(:supplier_transactions)
    .group("suppliers.id, suppliers.name")
    .select("suppliers.id, suppliers.name,
    SUM(CASE WHEN supplier_transactions.transaction_type = 'purchase' THEN supplier_transactions.amount ELSE 0 END) -
    SUM(CASE WHEN supplier_transactions.transaction_type = 'payment' THEN supplier_transactions.amount ELSE 0 END) AS debt_amount")
    .having("debt_amount > 0")
    .order("debt_amount DESC")
  }

  def self.total_debt
    purchases = SupplierTransaction.where(transaction_type: "purchase").sum(:amount)
    payments = SupplierTransaction.where(transaction_type: "payment").sum(:amount)
    purchases - payments
  end

  def total_due
    supplier_transactions.where(transaction_type: "purchase").sum(:amount) - supplier_transactions.where(transaction_type: "payment").sum(:amount)
  end
end
