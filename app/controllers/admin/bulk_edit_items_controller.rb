# frozen_string_literal: true

module Admin
  class BulkEditItemsController < AdminController
    def online
      items = Item.where(id: params[:item_ids].split(','))
      items.update_all(status: :active)
      redirect_to admin_items_path
    end

    def offline
      items = Item.where(id: params[:item_ids].split(','))
      items.update_all(status: :offline)
      redirect_to admin_items_path
    end
  end
end
