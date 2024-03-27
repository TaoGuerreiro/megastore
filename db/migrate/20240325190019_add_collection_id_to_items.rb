class AddCollectionIdToItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :items, :collection, null: true, foreign_key: true
  end
end
