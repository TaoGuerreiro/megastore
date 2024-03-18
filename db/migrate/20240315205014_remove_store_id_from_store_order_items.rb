class RemoveStoreIdFromStoreOrderItems < ActiveRecord::Migration[7.0]
  def change
    remove_reference :store_order_items, :store, null: false, foreign_key: true
  end
end
