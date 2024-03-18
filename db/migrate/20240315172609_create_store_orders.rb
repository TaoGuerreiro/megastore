class CreateStoreOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :store_orders do |t|
      t.string :status
      t.monetize :amount
      t.references :store, null: false, foreign_key: true
      t.string :ref
      t.date :date
      t.integer :endi_id
      t.text :comment

      t.timestamps
    end
  end
end
