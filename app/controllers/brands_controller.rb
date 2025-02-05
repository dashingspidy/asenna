class BrandsController < ApplicationController
  def index
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      flash[:success] = "Brand created successfully."
      redirect_to brands_path
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name)
  end
end
