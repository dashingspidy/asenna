class CartController < ApplicationController
  def show
    @cart = session[:cart] || {}
    @cart_discount = session[:cart_discount] || 0
    @cart_items = load_cart_items
    @payment_method = session[:payment_method]
  end

  def add
    session[:cart] ||= {}
    product_id = params[:product_id].to_s
    product = Product.find(product_id)

    inventory_quantity = product.inventories.sum(:quantity)
    current_quantity = session[:cart][product_id]&.dig("quantity").to_i

    if inventory_quantity > 0 && current_quantity < inventory_quantity
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

  def update_quantity
    product_id = params[:product_id].to_s
    new_quantity = params[:quantity].to_i

    product = Product.find(product_id)
    inventory_quantity = product.inventories.sum(:quantity)

    if inventory_quantity > 0 && new_quantity <= inventory_quantity && new_quantity > 0
      session[:cart][product_id]["quantity"] = new_quantity
    else
      flash[:error] = "Invalid quantity. Maximum available: #{inventory_quantity}"
    end

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
    end
  end

  def update_cart_discount
    discount = params[:discount].to_i

    if discount >= 0 && discount <= 100
      session[:cart_discount] = discount
    else
      flash[:error] = "Invalid discount percentage"
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("add-cart", partial: "cart/cart_items", locals: {
            cart: session[:cart],
            cart_discount: session[:cart_discount],
            payment_method: session[:payment_method]
          })
        ]
      end
    end
  end

  def update_payment_method
    payment_method = params[:payment_method]

    if [ "cash", "online" ].include?(payment_method)
      session[:payment_method] = payment_method
    else
      flash[:error] = "Invalid payment method"
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("flash-messages", partial: "layouts/flash"),
          turbo_stream.update("payment-method", partial: "cart/payment_method", locals: {
            payment_method: session[:payment_method]
          })
        ]
      end
    end
  end

  def remove
    product_id = params[:product_id].to_s
    session[:cart].delete(product_id)

    redirect_to cart_path
  end

  def checkout
    return redirect_to cart_path, alert: "Cart is empty" if session[:cart].blank?
    return redirect_to cart_path, alert: "Please select a payment method" if session[:payment_method].blank?

    ActiveRecord::Base.transaction do
      begin
        # Calculate total price after discount
        subtotal = session[:cart].sum do |_, details|
          details["price"].to_f * details["quantity"].to_i
        end

        discount = session[:cart_discount] || 0
        total_price = subtotal * (1 - discount / 100.0)

        # Create the sale record
        sale = Sale.create!(
          total_price: total_price,
          payment_method: session[:payment_method].strip
        )

        # Process each cart item
        session[:cart].each do |product_id, details|
          product = Product.find(product_id)
          requested_quantity = details["quantity"].to_i

          # Check if we have enough total inventory
          total_inventory = product.inventories.sum(:quantity)
          if total_inventory < requested_quantity
            raise ActiveRecord::RecordInvalid.new("Insufficient inventory for #{product.name}")
          end

          # Create sale item
          sale.sale_items.create!(
            product_id: product_id,
            quantity: requested_quantity,
            price: details["price"]
          )

          # Update inventories starting with the ones that have the most stock
          remaining_quantity = requested_quantity
          product.inventories.order(quantity: :desc).each do |inventory|
            break if remaining_quantity == 0

            inventory.lock! # Add explicit row-level locking
            if inventory.quantity > 0
              deduct_quantity = [ inventory.quantity, remaining_quantity ].min
              new_quantity = inventory.quantity - deduct_quantity

              if inventory.update!(quantity: new_quantity)
                StockTransaction.create!(
                  inventory: inventory,
                  transaction_type: "sale",
                  quantity: -deduct_quantity
                )
                remaining_quantity -= deduct_quantity
              end
            end
          end
        end

        # Clear cart after successful sale
        session[:cart] = nil
        session[:cart_discount] = nil
        session[:payment_method] = nil

        flash[:success] = "Order completed successfully!"
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
      rescue ActiveRecord::RecordInvalid => e
        flash[:error] = e.message
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update("flash-messages", partial: "layouts/flash")
          end
          format.html { redirect_to cart_path }
        end
      end
    end
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
