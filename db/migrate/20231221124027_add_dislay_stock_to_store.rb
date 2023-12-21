class AddDislayStockToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :display_stock, :boolean, default: false
  end
end
