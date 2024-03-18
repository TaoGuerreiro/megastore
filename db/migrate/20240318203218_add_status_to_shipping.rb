class AddStatusToShipping < ActiveRecord::Migration[7.0]
  def change
    add_column :shippings, :status, :string, default: "pending"
  end
end
