# frozen_string_literal: true

class AddAddressesInformationToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :postal_code, :string
    add_column :stores, :city, :string
    add_column :stores, :country, :string
    add_column :stores, :address, :string
  end
end
