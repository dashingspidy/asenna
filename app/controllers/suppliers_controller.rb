class SuppliersController < ApplicationController
  def index
    @supplier = Supplier.new
    @suppliers = Supplier.all
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
      flash[:success] = "Supplier added successfully"
      redirect_to suppliers_path
    else
      flash[:error] = @supplier.errors.full_messages.join(", ")
      redirect_to suppliers_path
    end
  end

  private

  def supplier_params
    params.expect(supplier: [ :name, :email, :phone, :brand_id ])
  end
end
