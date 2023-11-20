class OrdersController < ApplicationController

  def show
    @order = Order.find(params[:id])
    @items = Checkout.new(@order.items.pluck(:id)).cart

    if @order.paid?
      session.clear
      session[:checkout_items] = []
    end
  end
end
