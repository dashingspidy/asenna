class CartController < ApplicationController
  def show
    @cart = session[:cart] || {}
    @cart_items = load_cart_items
  end

  def add
    session[:cart] ||= {}
    product_id = params[:product_id].to_s
    product = Product.find(product_id)

    inventory_quantity = product.inventories.sum(:quantity)
    current_quantity = session[:cart][product_id]&.dig("quantity").to_i

    if current_quantity < inventory_quantity
      session[:cart][product_id] ||= {
        "quantity" => 0,
        "price" => product.price,
        "name" => product.name
      }
      session[:cart][product_id]["quantity"] += 1
    else
      flash[:error] = "Only #{inventory_quantity} available in stock."
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("add-cart", partial: "cart/cart_items", locals: { cart: session[:cart] })
        ]
      end
      format.html { redirect_to cart_path }
    end
  end

  def remove
    product_id = params[:product_id].to_s
    session[:cart].delete(product_id)

    redirect_to cart_path
  end

  def search
    query = params[:query].strip
    @products = query.present? ? Product.joins(:inventories).where("LOWER(products.name) LIKE ?", "%#{query.downcase}%").distinct : Product.none
    render :show, locals: { products: @products }
  end

  private

  def load_cart_items
    return [] if session[:cart].blank?
    product_ids = session[:cart].keys
    Product.where(id: product_ids).index_by(&:id)
  end
end
