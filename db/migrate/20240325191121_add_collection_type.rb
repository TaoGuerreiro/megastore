class AddCollectionType < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :collection_type, :string
  end
end
