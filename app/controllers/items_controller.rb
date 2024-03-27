# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_virtual_stock, only: [:show]

  def show
    @item = Item.find(params[:id])

    if params[:collection]
      @item = Item.find(params[:collection])
      respond_to { |format| format.turbo_stream { render turbo_stream: turbo_stream.update("store-item-show", partial: 'items/item', locals: { item: @item }) }}
    else
      respond_to { |format| format.html }
    end
  end

  private

  # This method is used to calculate the virtual stock of an item.
  def set_virtual_stock
    @item = Item.find(params[:id])
    cart_stock = Checkout.new(session[:checkout_items]).cart.find do |item|
                   item[:item].id == @item.id
                 end&.[](:number) || 0
    @virtual_stock = @item.stock - cart_stock
  end
end
