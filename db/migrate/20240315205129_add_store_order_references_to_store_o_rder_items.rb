class AddStoreOrderReferencesToStoreORderItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :store_order_items, :store_order, null: false, foreign_key: true
  end
end
