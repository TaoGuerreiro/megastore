# frozen_string_literal: true

class AddWeigthToShippingMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :shipping_methods, :max_weight, :integer
  end
end
