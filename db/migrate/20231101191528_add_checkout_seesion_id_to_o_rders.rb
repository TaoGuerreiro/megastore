# frozen_string_literal: true

class AddCheckoutSeesionIdToORders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :checkout_session_id, :string
  end
end
