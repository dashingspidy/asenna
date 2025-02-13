class CreateStockTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_transactions do |t|
      t.references :inventory, null: false, foreign_key: true
      t.string :transaction_type
      t.integer :quantity

      t.timestamps
    end
  end
end
