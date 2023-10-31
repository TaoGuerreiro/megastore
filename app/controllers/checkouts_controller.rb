class CheckoutsController < ApplicationController
  def add
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])
    session[:checkout_items] << @item.id

    redirect_to item_path(@item), notice: "#{@item.name} ajouté au panier"
  end
end
