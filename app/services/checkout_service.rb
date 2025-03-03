class CheckoutService
  def initialize(cart:, payment_method:, discount:, customer_id: nil, paying_amount: nil)
    @cart = cart
    @payment_method = payment_method
    @discount = discount
    @customer_id = customer_id
    @paying_amount = paying_amount.to_f
  end

  def process
    ActiveRecord::Base.transaction do
      begin
        create_sale
        process_inventory
        if @customer_id.present?
          create_customer_transaction("purchase", calculate_total_price)
          create_customer_transaction("payment", @paying_amount) if @paying_amount.positive?
        end
        yield(true, "Order completed successfully!")
      rescue ActiveRecord::RecordInvalid => e
        yield(false, e.message)
      end
    end
  end

  private

  def create_sale
    @sale = Sale.create!(
      total_price: calculate_total_price,
      payment_method: @payment_method.strip,
      customer_id: @customer_id
    )

    @cart.each do |product_id, details|
      @sale.sale_items.create!(
        product_id: product_id,
        quantity: details["quantity"].to_i,
        price: details["price"]
      )
    end
  end

  def create_customer_transaction(transaction_type, amount)
    CustomerTransaction.create!(
      customer_id: @customer_id,
      transaction_type: transaction_type,
      amount: amount,
      date: Date.current
    )
  end

  def calculate_total_price
    subtotal = @cart.sum do |_, details|
      details["price"].to_f * details["quantity"].to_i
    end
    subtotal * (1 - (@discount || 0) / 100.0)
  end

  def process_inventory
    @cart.each do |product_id, details|
      product = Product.find(product_id)
      requested_quantity = details["quantity"].to_i

      validate_inventory(product, requested_quantity)
      update_inventory(product, requested_quantity)
    end
  end

  def validate_inventory(product, requested_quantity)
    total_inventory = product.inventories.sum(:quantity)
    if total_inventory < requested_quantity
      raise ActiveRecord::RecordInvalid.new("Insufficient inventory for #{product.name}")
    end
  end

  def update_inventory(product, requested_quantity)
    remaining_quantity = requested_quantity

    product.inventories.order(quantity: :desc).each do |inventory|
      break if remaining_quantity.zero?

      inventory.lock!
      if inventory.quantity > 0
        deduct_quantity = [ inventory.quantity, remaining_quantity ].min
        new_quantity = inventory.quantity - deduct_quantity

        if inventory.update!(quantity: new_quantity)
          create_stock_transaction(inventory, deduct_quantity)
          remaining_quantity -= deduct_quantity
        end
      end
    end
  end

  def create_stock_transaction(inventory, deduct_quantity)
    StockTransaction.create!(
      inventory: inventory,
      transaction_type: "sale",
      quantity: -deduct_quantity
    )
  end
end
