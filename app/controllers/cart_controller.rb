class CartController < ApplicationController
  before_action :load_cart
  before_action :load_products, only: [ :show, :search ]

  def show
  end

  def add
    product = find_product
    if can_add_to_cart?(product)
      add_to_cart(product)
    else
      flash[:error] = "Only #{available_quantity(product)} available in stock."
    end
    respond_with_cart_update
  end

  def update_quantity
    product = find_product
    new_quantity = params[:quantity].to_i

    if valid_quantity?(product, new_quantity)
      update_item_quantity(product.id.to_s, new_quantity)
    else
      flash[:error] = "Invalid quantity. Maximum available: #{available_quantity(product)}"
    end
    respond_with_cart_update
  end

  def update_cart_discount
    discount = params[:discount].to_i
    if valid_discount?(discount)
      session[:cart_discount] = discount
    else
      flash[:error] = "Invalid discount percentage"
    end
    respond_with_cart_update
  end

  def update_payment_method
    payment_method = params[:payment_method]
    if valid_payment_method?(payment_method)
      session[:payment_method] = payment_method
    else
      flash[:error] = "Invalid payment method"
    end
    respond_with_payment_update
  end

  def remove
    remove_from_cart(params[:product_id].to_s)
    clear_cart_if_empty
    respond_with_cart_update
  end

  def checkout
    return handle_invalid_checkout unless valid_checkout?

    CheckoutService.new(cart: @cart,
                       payment_method: @payment_method,
                       discount: @cart_discount).process do |success, message|
      if success
        clear_cart
        flash[:success] = message
      else
        flash[:error] = message
      end
    end

    respond_with_checkout_update
  end

  def search
    @products = params[:query].strip.present? ?
      Product.search_by_name(params[:query].strip) :
      Product.most_sold
    render :show, locals: { products: @products }
  end

  private

  def load_cart
    @cart = session[:cart] || {}
    @cart_discount = session[:cart_discount] || 0
    @cart_items = load_cart_items
    @payment_method = session[:payment_method]
  end

  def load_products
    @products = Product.most_sold
  end

  def load_cart_items
    return [] if session[:cart].blank?
    Product.where(id: session[:cart].keys).index_by(&:id)
  end

  def find_product
    Product.find(params[:product_id].to_s)
  end

  def available_quantity(product)
    product.inventories.sum(:quantity)
  end

  def can_add_to_cart?(product)
    current_quantity = (@cart[product.id.to_s] || {})["quantity"].to_i
    available_quantity(product) > 0 && current_quantity < available_quantity(product)
  end

  def add_to_cart(product)
    product_id = product.id.to_s
    current_quantity = (@cart[product_id] || {})["quantity"].to_i

    @cart[product_id] = {
      "quantity" => current_quantity + 1,
      "price" => product.price,
      "name" => product.name
    }

    session[:cart] = @cart
  end

  def valid_quantity?(product, quantity)
    quantity > 0 && quantity <= available_quantity(product)
  end

  def update_item_quantity(product_id, quantity)
    session[:cart][product_id]["quantity"] = quantity
  end

  def valid_discount?(discount)
    discount.between?(0, 100)
  end

  def valid_payment_method?(payment_method)
    [ "cash", "online" ].include?(payment_method)
  end

  def remove_from_cart(product_id)
    session[:cart].delete(product_id)
  end

  def clear_cart_if_empty
    if session[:cart].empty?
      clear_cart
    end
  end

  def clear_cart
    session[:cart] = nil
    session[:cart_discount] = nil
    session[:payment_method] = nil
  end

  def valid_checkout?
    session[:cart].present? && session[:payment_method].present?
  end

  def handle_invalid_checkout
    message = session[:cart].blank? ? "Cart is empty" : "Please select a payment method"
    redirect_to cart_path, alert: message
  end

  def respond_with_cart_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("add-cart", partial: "cart/cart_items", locals: {
            cart: session[:cart],
            cart_discount: session[:cart_discount] || 0,
            payment_method: session[:payment_method]
          })
        ]
      end
      format.html { redirect_to cart_path }
    end
  end

  def respond_with_payment_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("payment-method", partial: "cart/payment_method", locals: {
            payment_method: session[:payment_method]
          }),
          turbo_stream.update("add-cart", partial: "cart/cart_items", locals: {
            cart: session[:cart],
            cart_discount: session[:cart_discount] || 0,
            payment_method: session[:payment_method]
          })
        ]
      end
    end
  end

  def respond_with_checkout_update
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("add-cart", partial: "cart/cart_items", locals: {
            cart: {},
            cart_discount: 0,
            payment_method: nil
          }),
          turbo_stream.update("payment-method", partial: "cart/payment_method", locals: {
            payment_method: nil
          })
        ]
      end
      format.html { redirect_to cart_path }
    end
  end
end
