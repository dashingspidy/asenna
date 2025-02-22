class SuppliersController < ApplicationController
  before_action :set_supplier, only: %i[ edit update ]
  def index
    @supplier = Supplier.new
    @pagy, @suppliers = pagy(Supplier.all, limit: 15)
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

  def edit
    @pagy, @suppliers = pagy(Supplier.all, limit: 15)
    render :index
  end

  def update
    if @supplier.update(supplier_params)
      flash[:success] = "Supplier details updated."
      redirect_to suppliers_path
    else
      flash[:error] = @supplier.errors.full_messages.join(", ")
      redirect_to suppliers_path
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.expect(supplier: [ :name, :email, :phone, :brand_id ])
  end
end
