# frozen_string_literal: true

class OrdersController < ApplicationController
  def show
    @order = Order.find(params[:id])
    @items = Checkout.new(@order.items.pluck(:id)).cart
    return unless @order.paid?

    # session.clear
    session[:checkout_items] = []
  end
end
