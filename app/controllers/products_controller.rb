class ProductsController < ApplicationController
  def index
    @products = Product.includes(:brand).all.limit(10)
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      flash[:success] = "Product created successfully."
      redirect_to products_path
    else
      flash[:error] = @product.errors.full_messages.join(", ")
      redirect_to products_path
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :brand_id)
  end
end
