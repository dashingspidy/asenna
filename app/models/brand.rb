class Brand < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :suppliers, dependent: :destroy

  normalizes :name, with: ->(value) { value.downcase.strip }

  validates :name, presence: true, uniqueness: true
end
