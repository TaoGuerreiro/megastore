class AddParcelInformationToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :api_tracking_number, :string
    add_column :orders, :api_tracking_url, :string
    add_column :orders, :api_shipping_method_name, :string
  end
end
