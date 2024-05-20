# frozen_string_literal: true

class CartsController < ApplicationController
  def add
    manage_item_in_cart(:add)
  end

  def remove
    manage_item_in_cart(:remove)
  end

  private

  def manage_item_in_cart(action)
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])

    add_item_to_cart if action == :add
    remove_item_from_cart if action == :remove
    set_virtual_stock

    respond_to do |format|
      format.html { redirect_to item_path(@item), notice: }
      format.turbo_stream
    end
  end

  def add_item_to_cart
    session[:checkout_items] << @item.id
    "#{@item.name} ajouté au panier"
  end

  def remove_item_from_cart
    session[:checkout_items].delete_at session[:checkout_items].index @item.id
    @opened = true
    "#{@item.name} supprimé panier"
  end

  def set_virtual_stock
    @item = Item.find(params[:item_id])
    cart_stock = Checkout.new(session[:checkout_items]).cart.find do |item|
                   item[:item].id == @item.id
                 end&.[](:number) || 0
    @virtual_stock = @item.stock - cart_stock
  end
end
