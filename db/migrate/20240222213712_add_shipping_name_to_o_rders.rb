# frozen_string_literal: true

class AddShippingNameToORders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shipping_full_name, :string
  end
end
