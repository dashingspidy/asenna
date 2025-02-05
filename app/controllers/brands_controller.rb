class BrandsController < ApplicationController
  def index
    @brands = Brand.all.limit(20)
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      flash[:success] = "Brand created successfully."
      redirect_to brands_path
    else
      flash[:error] = @brand.errors.full_messages.join(", ")
      render :index, status: :unprocessable_entity
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name)
  end
end
