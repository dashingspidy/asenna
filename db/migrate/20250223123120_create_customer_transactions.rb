class CreateCustomerTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_transactions do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :transaction_type
      t.decimal :amount, null: false
      t.date :date

      t.timestamps
    end
  end
end
