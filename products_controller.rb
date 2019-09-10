class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  def index
    @products = Product.all
    authorize(@products)
  end

  def new
    @product = Product.new
    @categories = Category.all
  end

  def edit
    @category = Category.all
    authorize(@product)
  end

  def create
    binding.pry
    params[:product][:remaining_quantity] = params[:product][:quantity]
    @product = Product.new(product_params)
    authorize(@product)
    if @product.save
      redirect_to :root, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize(@product)
    if @product.update(product_params)
      redirect_to :root, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize(@product)
    @product.destroy
    redirect_to products_url, notice: 'Product was successfully destroyed.'
  end

  def show

  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :category_id, :quantity, :description, :remaining_quantity, :code)
  end
end
