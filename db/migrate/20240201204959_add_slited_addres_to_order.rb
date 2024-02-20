# frozen_string_literal: true

class AddSlitedAddresToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :shipping_country, :string
    add_column :orders, :shipping_city, :string
    add_column :orders, :shipping_postal_code, :string
    add_column :orders, :weight, :string
  end
end
