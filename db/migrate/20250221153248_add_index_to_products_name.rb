class AddIndexToProductsName < ActiveRecord::Migration[8.0]
  def change
    add_index :products, :name
  end
end
