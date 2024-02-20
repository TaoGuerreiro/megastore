# frozen_string_literal: true

class AddColumnsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_monetize :orders, :shipping_cost
    add_column :orders, :shipping_method_carrier, :string
    add_column :orders, :shipping_service_point_address, :string
    add_column :orders, :shipping_service_point_name, :string
  end
end
