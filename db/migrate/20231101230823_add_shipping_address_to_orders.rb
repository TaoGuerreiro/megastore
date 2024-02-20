# frozen_string_literal: true

class AddShippingAddressToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shipping_address, :string
  end
end
