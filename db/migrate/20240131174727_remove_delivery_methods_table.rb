# frozen_string_literal: true

class RemoveDeliveryMethodsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :item_shipments
    drop_table :delivery_methods
  end
end
