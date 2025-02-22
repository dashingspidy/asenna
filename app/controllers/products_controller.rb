class ProductsController < ApplicationController
  before_action :set_product, only: %i[ edit update ]
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

  def edit
    @products = Product.includes(:brand).all.limit(10)
    render :index
  end

  def update
    if @product.update(product_params)
      flash.now[:success] = "Product updated successfully."
      redirect_to products_path
    else
      flash.now[:error] = @product.errors.full_messages.join(", ")
      redirect_to products_path
    end
  end

  def search
    @q = Product.ransack(name_cont: params[:q])
    @products = @q.result(distinct: true).limit(10)

    render json: @products.map { |product|
      {
        id: product.id,
        name: product.name,
        brand: product.brand.name
      }
    }
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :brand_id)
  end
end
