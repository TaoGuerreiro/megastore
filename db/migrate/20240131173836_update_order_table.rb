class UpdateOrderTable < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :delivery_method_id
    add_column :orders, :api_shipping_id, :integer, null: true
    add_column :orders, :api_service_point_id, :integer, null: true
  end
end
