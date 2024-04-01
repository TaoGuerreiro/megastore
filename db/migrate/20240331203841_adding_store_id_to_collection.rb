class AddingStoreIdToCollection < ActiveRecord::Migration[7.0]
  def change
    add_reference :collections, :store, null: false, foreign_key: true
  end
end
