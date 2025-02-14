class SaleItem < ApplicationRecord
  belongs_to :sale
  belongs_to :product

  before_save :set_price

  private

  def set_price
    self.price = product.price
  end
end
