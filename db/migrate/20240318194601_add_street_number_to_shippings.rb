class AddStreetNumberToShippings < ActiveRecord::Migration[7.0]
  def change
    add_column :shippings, :street_number, :string
    add_column :shippings, :address_first_line, :string
    add_column :shippings, :address_second_line, :string
  end
end
