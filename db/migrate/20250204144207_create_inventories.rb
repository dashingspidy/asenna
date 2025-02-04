class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.integer :quantity, null: false
      t.string :location
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
