class CreateShippings < ActiveRecord::Migration[7.0]
  def change
    create_table :shippings do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :api_shipping_id
      t.integer :api_service_point_id
      t.string :api_tracking_number
      t.string :api_tracking_url
      t.string :api_method_name
      t.integer :parcel_id
      t.string :method_carrier
      t.string :service_point_address
      t.string :service_point_name

      t.monetize :cost

      t.string :address, null: :false
      t.string :country, null: :false
      t.string :city, null: :false
      t.string :postal_code, null: :false
      t.string :weight, null: :false
      t.string :full_name, null: :false

      t.timestamps
    end

    remove_column :orders, :api_shipping_id
    remove_column :orders, :api_service_point_id
    remove_column :orders, :api_tracking_number
    remove_column :orders, :shipping_cost_cents
    remove_column :orders, :shipping_cost_currency

    remove_column :orders, :api_tracking_url
    remove_column :orders, :api_shipping_method_name
    remove_column :orders, :parcel_id
    remove_column :orders, :shipping_method_carrier
    remove_column :orders, :shipping_service_point_address
    remove_column :orders, :shipping_service_point_name
    remove_column :orders, :shipping_address
    remove_column :orders, :shipping_country
    remove_column :orders, :shipping_city
    remove_column :orders, :shipping_postal_code
    remove_column :orders, :shipping_full_name
    remove_column :orders, :weight
  end
end
