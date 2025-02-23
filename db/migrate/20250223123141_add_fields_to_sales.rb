class AddFieldsToSales < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :customer_id, :integer, null: true
    add_column :sales, :sale_number, :string

    add_foreign_key :sales, :customers, column: :customer_id
  end
end
