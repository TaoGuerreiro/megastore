class AddServiceToShippingMethods < ActiveRecord::Migration[7.0]
  def change
    add_column :shipping_methods, :service_name, :string
  end
end
