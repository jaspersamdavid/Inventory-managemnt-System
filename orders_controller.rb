class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]
  before_action :check_supplier_status, only: [:create]

  def index
    @orders = Order.all
    authorize(@orders)
    @suppliers = Supplier.all
    @products = Product.all
    @active = Order.active?
    @expired = Order.expired?
    @reviews = Review.all
    @bad_reviews = Review.where('rating <= ?', 3)
    @good_reviews = Review.where('rating > ?', 3)
  end

  def old
    @inactive = Order.inactive?
    authorize(@inactive)
  end

  def renew
    @current_user = current_user
    @order = Order.find_by_id(params[:id])
    Order.renew(params[:id])
    redirect_to :root
    flash[:notice] = "Renewed for 7 days from now. Enjoy!"

    begin
      OrderMailer.delay.renew_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  def return
    purchased_qty = Order.find_by_id(params[:id]).quantity.to_i
    @purchased_product = Order.find_by_id(params[:id]).product
    @purchased_product.decrement!(:remaining_quantity, purchased_qty)
    @current_user = current_user
    @order = Order.find_by_id(params[:id])
    Order.return(params[:id])
    redirect_to :root, notice: 'Product returned back to supplier.'

    begin
      OrderMailer.delay.return_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  def new
    @order = Order.new
    authorize(@order)
    @suppliers = Supplier.all
  end

  def create
    params[:order][:status] = true
    @order = Order.new(order_params)
    authorize(@order)
    if @order.save
      @current_user = current_user
      @purchased_product = Product.find_by_id(params[:order][:product_id])
      @purchased_product.increment!(:remaining_quantity, params[:order][:quantity].to_i)
      redirect_to :root, notice: 'Order was successfully created.'
      begin
        OrderMailer.delay.create_order(@order, @current_user).deliver
      rescue Exception => e
      end
    else
      flash[:alert] = 'Order creation was unsucessfull.'
      render :new
    end
  end

  def destroy
    authorize(@order)
    purchased_qty = @order.quantity.to_i
    @purchased_product = @order.product
    @purchased_product.decrement!(:remaining_quantity, purchased_qty)
    @current_user = current_user
    @order.destroy

    redirect_to orders_url, notice: 'Order was successfully destroyed.'
    begin
      OrderMailer.delay.cancel_order(@order, @current_user).deliver
    rescue Exception => e
    end
  end

  private

    def check_supplier_status
      return if params[:order][:supplier_id].blank?
      @supplier = Supplier.find(params[:order][:supplier_id])
      if @supplier.active?
        true
      else
        flash[:alert] = "The supplier you selected is currently #{@supplier.status}."
        false
      end
    end

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:quantity, :expire_at, :status, :product_id, :supplier_id)
    end

end







