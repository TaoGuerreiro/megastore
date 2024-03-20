class AddApiErrorToStoreOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :store_orders, :api_error, :text
  end
end
