# frozen_string_literal: true

class AddQuantityToOrderItems < ActiveRecord::Migration[7.0]
  def change
    add_column :order_items, :quantity, :integer, default: 0
  end
end
