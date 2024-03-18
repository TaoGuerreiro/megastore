class CreateStoreOrderItems < ActiveRecord::Migration[7.0]
  def change
    create_table :store_order_items do |t|
      t.references :store, null: false, foreign_key: true
      t.string :orderable_type, null: false
      t.bigint :orderable_id, null: false
      t.monetize :price

      t.timestamps
    end
  end
end
