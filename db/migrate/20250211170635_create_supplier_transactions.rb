class CreateSupplierTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :supplier_transactions do |t|
      t.references :supplier, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.decimal :amount, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
