class Brand < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :suppliers, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
