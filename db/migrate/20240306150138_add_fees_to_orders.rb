class AddFeesToOrders < ActiveRecord::Migration[7.0]
  def change
    add_monetize :orders, :fees
  end
end
