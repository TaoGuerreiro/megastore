class AddParcelIdToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :parcel_id, :integer
  end
end
