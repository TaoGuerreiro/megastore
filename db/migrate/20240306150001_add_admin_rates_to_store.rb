class AddAdminRatesToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :rates, :float, default: 0.20
  end
end
