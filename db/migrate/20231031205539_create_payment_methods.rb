# frozen_string_literal: true

class CreatePaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_methods do |t|
      t.string :name
      t.string :description
      t.monetize :price
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
