class BrandsController < ApplicationController
  def index
    @brand = Brand.new
  end

  def create
    @brand = Brand.new(brand_params)
    if @brand.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to brands_path, success: "Brand created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("brand-form", partial: "brands/form", formats: :html, locals: { brand: @brand }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def brand_params
    params.require(:brand).permit(:name)
  end
end
