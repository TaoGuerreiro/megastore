# frozen_string_literal: true

module Admin
  class BulkEditItemsController < AdminController
    def online
      updated_items = Item.where(id: params[:item_ids].split(','))
      updated_items.update_all(status: :active)

      items = filterable(Item, authorized_scope(Item.includes(:photos, :category)))

      respond_to do |format|
        format.html { redirect_to admin_items_path }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('items', partial: 'admin/items/items', locals: { items: }) }
      end
    end

    def offline
      items = Item.where(id: params[:item_ids].split(','))
      items.update_all(status: :offline)

      items = filterable(Item, authorized_scope(Item.includes(:photos, :category)))

      respond_to do |format|
        format.html { redirect_to admin_items_path }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('items', partial: 'admin/items/items', locals: { items: }) }
      end
    end

    def add_to_collection
      items = Item.where(id: params[:item_ids].split(','))
      collection = Collection.find(params[:collection_id])
      items.update_all(collection_id: collection.id)
      redirect_to admin_items_path
    end
  end
end
