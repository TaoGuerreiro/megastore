class AddApiErrorToShippings < ActiveRecord::Migration[7.0]
  def change
    add_column :shippings, :api_error, :text
  end
end
