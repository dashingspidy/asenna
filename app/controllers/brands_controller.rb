class BrandsController < ApplicationController
  before_action :set_brand, only: %i[ edit update ]
  def index
    @pagy, @brands = pagy(Brand.all, limit: 15)
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      flash[:success] = "Brand created successfully."
      redirect_to brands_path
    else
      flash[:error] = @brand.errors.full_messages.join(", ")
      redirect_to brands_path
    end
  end

  def edit
    @pagy, @brands = pagy(Brand.all, limit: 15)
    render :index
  end

  def update
    if @brand.update(brand_params)
      flash[:success] = "Brand updated successfully."
      redirect_to brands_path
    else
      flash[:error] = @brand.errors.full_messages.join(", ")
      redirect_to brands_path
    end
  end

  private

  def set_brand
    @brand = Brand.find(params[:id])
  end

  def brand_params
    params.require(:brand).permit(:name)
  end
end
