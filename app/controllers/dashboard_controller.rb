class DashboardController < ApplicationController
  def index
    @sales_data = Sale.sales_insight
    @total_week = Sale.total_by_week
    @customer = Sale.total_customer_today
    @low_stock_products = Product.joins(:inventories).merge(Inventory.low_stock)
    @top_selling_products = Product.top_selling
    @top_selling_brands = Brand.top_selling
    @total_debt = Supplier.total_debt
    @supplier_debts = Supplier.debt_per_supplier
  end

  def sales_chart_data
    data = case params[:range]
    when "weekly"
      Sale.total_by_week
    when "monthly"
      Sale.group_by_month_of_year(:created_at, format: "%B").sum(:total_price)
    when "yearly"
      Sale.group_by_year(:created_at, format: "%Y").sum(:total_price)
    else
      Sale.total_by_week
    end

    render json: data
  end
end
