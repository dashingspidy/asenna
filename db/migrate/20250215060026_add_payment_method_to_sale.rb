class AddPaymentMethodToSale < ActiveRecord::Migration[8.0]
  def change
    add_column :sales, :payment_method, :string
  end
end
