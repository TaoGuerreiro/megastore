class ItemsController < ApplicationController
  before_action :set_virtual_stock, only: [:show]

  def show
    @item = Item.find(params[:id])
  end

  private

  # This method is used to calculate the virtual stock of an item.
  def set_virtual_stock
    @item = Item.find(params[:id])
    cart_stock = Checkout.new(session[:checkout_items]).cart.find { |item| item[:item].id == @item.id }&.[](:number) || 0
    @virtual_stock = @item.stock - cart_stock
  end
end
