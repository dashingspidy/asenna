class InventoriesController < ApplicationController
  def index
    @pagy, @inventories = pagy(Inventory.all, limit: 15)
    @inventory = Inventory.new
  end

  def create
    @inventory = Inventory.find_or_initialize_by(product_id: inventory_params[:product_id])
    if @inventory.new_record?
      @inventory.assign_attributes(inventory_params)
    else
      @inventory.quantity += inventory_params[:quantity].to_i
    end

    if @inventory.save
      StockTransaction.create!(
        inventory: @inventory,
        transaction_type: "stock_in",
        quantity: inventory_params[:quantity].to_i
      )
      flash[:success] = "Product Stock added."
      redirect_to inventories_path
    else
      flash[:error] = @inventory.errors.full_messages.join(", ")
      redirect_to inventories_path
    end
  end

  def show
    @stocks = Inventory.find(params[:id])
  end

  private

  def inventory_params
    params.expect(inventory: [ :product_id, :quantity, :location ])
  end
end
