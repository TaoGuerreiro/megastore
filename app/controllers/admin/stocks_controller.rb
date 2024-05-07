# frozen_string_literal: true

module Admin
  class StocksController < AdminController
    def add_stock
      @item = Item.find(params[:id])
      authorize! @item
      @item.stock += 1
      @item.save
      respond_to do |format|
        format.html { redirect_to admin_items_path, notice: t(".success") }
        format.turbo_stream
      end
    end

    def remove_stock
      @item = Item.find(params[:id])
      authorize! @item
      @item.stock -= 1
      @item.save
      respond_to do |format|
        format.html { redirect_to admin_items_path, notice: t(".success") }
        format.turbo_stream
      end
    end
  end
end
