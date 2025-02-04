class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :description
      t.decimal :price
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
