# frozen_string_literal: true

class AddRsUrl < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :instagram_url, :string
    add_column :stores, :facebook_url, :string
  end
end
