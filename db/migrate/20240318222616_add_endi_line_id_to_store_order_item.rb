class AddEndiLineIdToStoreOrderItem < ActiveRecord::Migration[7.0]
  def change
    add_column :store_order_items, :endi_line_id, :integer
  end
end
