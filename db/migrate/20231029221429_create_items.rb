# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name
      t.integer :price_cents
      t.string :price_currency
      t.references :store, null: false, foreign_key: true
      t.integer :stock
      t.integer :weight
      t.integer :length
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
