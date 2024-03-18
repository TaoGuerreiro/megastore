class AddDefaultStatusToStoreOrderToPending < ActiveRecord::Migration[7.0]
  def change
    change_column_default :store_orders, :status, from: nil, to: "pending"
  end
end
