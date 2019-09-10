class HomeController < ApplicationController

  # skip_before_action :authenticate_user!

  def index

  end

  def customer_dashboard
    @suppliers = Supplier.all
    @products = Product.all
  end
end
