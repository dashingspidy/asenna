class DashboardController < ApplicationController
  def index
    @sales_data = Sale.sales_insight
    @total_week = Sale.total_by_week
    @customer = Sale.total_customer_today
    @low_stock_products = Product.joins(:inventories).merge(Inventory.low_stock)
    @top_selling_products = Product.top_selling
    @top_selling_brands = Brand.top_selling
    @supplier_balance = Supplier.supplier_balance
  end
end
