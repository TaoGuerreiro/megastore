class AddFiltersOptionToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :filters, :boolean, default: true
  end
end
