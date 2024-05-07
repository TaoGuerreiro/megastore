class AddUniqueIndexToStoresSlug < ActiveRecord::Migration[7.0]
  def change
    add_index :stores, :slug, unique: true
  end
end
