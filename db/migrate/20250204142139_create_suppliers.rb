class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :email
      t.integer :phone, null: false
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
  end
end
