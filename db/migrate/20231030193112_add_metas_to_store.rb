# frozen_string_literal: true

class AddMetasToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :meta_title, :string
    add_column :stores, :meta_description, :string
    add_column :stores, :meta_image, :string
  end
end
