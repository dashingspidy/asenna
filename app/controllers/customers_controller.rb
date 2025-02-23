class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ edit update show ]
  def index
    @customer = Customer.new
    @pagy, @customers = pagy(Customer.all, limit: 15)
  end

  def create
    @customer = Customer.new(customer_params)
    if @customer.save
      flash[:success] = "Customer added successfully"
      redirect_to customers_path
    else
      flash[:error] = @customer.errors.full_messages.join(", ")
      redirect_to customers_path
    end
  end

  def show
    @customer_transaction = CustomerTransaction.new
  end

  def create_transaction
    @customer = Customer.find(params[:id])
    @customer_transaction = @customer.customer_transactions.build(customer_transaction_params)

    if @customer_transaction.save
      flash[:success] = "Customer transaction added successfully"
      redirect_to customer_path(@customer)
    else
      flash[:error] = @customer_transaction.errors.full_messages.join(", ")
      render :show
    end
  end

  def edit
    @pagy, @customers = pagy(Customer.all, limit: 15)
    render :index
  end

  def update
    if @customer.update(customer_params)
      flash[:success] = "Customer details updated."
      redirect_to customers_path
    else
      flash[:error] = @customer.errors.full_messages.join(", ")
      redirect_to customers_path
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.expect(customer: [ :name, :email, :phone, :brand_id ])
  end

  def customer_transaction_params
    params.require(:customer_transaction).permit(:customer_id, :amount, :date, :transaction_type)
  end
end
