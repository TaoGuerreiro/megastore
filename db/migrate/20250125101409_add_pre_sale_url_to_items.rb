class AddPreSaleUrlToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :pre_sale_url, :string
  end
end
