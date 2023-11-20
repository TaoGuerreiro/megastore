class CreateItemShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :item_shipments do |t|
      t.references :item, null: false, foreign_key: true
      t.references :shipping_method, null: false, foreign_key: true

      t.timestamps
    end
  end
end
