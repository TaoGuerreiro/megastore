# frozen_string_literal: true

class AddActiveToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :active, :boolean
  end
end
