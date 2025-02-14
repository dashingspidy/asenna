class Sale < ApplicationRecord
  has_many :sale_items, dependent: :destroy
  has_many :products, through: :sale_items

  before_save :calculate_total

  private

  def calculate_total
    self.total = sale_items.sum { |item| item.quantity * item.price }
  end
end
