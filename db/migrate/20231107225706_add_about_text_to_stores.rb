# frozen_string_literal: true

class AddAboutTextToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :about_text, :string
  end
end
