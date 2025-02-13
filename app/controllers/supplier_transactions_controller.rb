class SupplierTransactionsController < ApplicationController
  def index
    @transactions = SupplierTransaction.order(date: :desc)
    @transaction = SupplierTransaction.new
  end

  def create
    @supplier_transaction = SupplierTransaction.new(supplier_transactions_params)
    if @supplier_transaction.save
      flash[:success] = "Transaction saved."
      redirect_to supplier_transactions_path
    else
      flash[:error] = @supplier_transaction.errors.full_messages.join(", ")
      redirect_to supplier_transactions_path
    end
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  private

  def supplier_transactions_params
    params.expect(supplier_transaction: [ :supplier_id, :transaction_type, :amount, :date ])
  end
end
