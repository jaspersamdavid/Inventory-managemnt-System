class TransactionsController < ApplicationController
  before_action :set_transaction, only: [:show, :edit, :update, :destroy]
  before_action :check_supplier_status, only: [:create]

  def index
    @transactions = Transaction.all
    authorize(@transactions)
  end

  def show
  end

  def new
    @transaction = Transaction.new
    authorize(@transaction)
    @products = Product.all
    @suppliers = Supplier.active
  end

  def edit
    authorize(@transaction)
    @suppliers = Supplier.active
    @products = Product.all
  end


  def create
    @transaction = Transaction.new(transaction_params)
    authorize(@transaction)
    if @transaction.save
      @current_user = current_user
      @transacted_product = Product.find_by_id(params[:transaction][:product_id])
      @transacted_product.decrement!(:remaining_quantity, params[:transaction][:quantity].to_i)
      redirect_to transactions_path, notice: 'Transaction was successfully created.'
    else
      flash[:alert] = 'Transaction creation was unsucessfull.'
      render :new
    end
  end

  def update
    authorize(@transaction)
    respond_to do |format|
      if @transaction.update(transaction_params)
        format.html { redirect_to transactions_path, notice: 'Transaction was successfully updated.' }
        format.json { render :show, status: :ok, location: @transaction }
      else
        format.html { render :edit }
        format.json { render json: @transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize(@transaction)
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_path, notice: 'Transaction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def check_supplier_status
      return if params[:transaction][:supplier_id].blank?
      @supplier = Supplier.find(params[:transaction][:supplier_id])
      if @supplier.active?
        true
      else
        flash[:alert] = "The supplier you selected is currently #{@supplier.status}."
        false
        redirect_to products_path
      end
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def transaction_params
      params.require(:transaction).permit(:transaction_id, :product_id, :supplier_id, :quantity)
    end
end
