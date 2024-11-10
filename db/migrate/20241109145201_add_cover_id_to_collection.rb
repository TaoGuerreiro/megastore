class AddCoverIdToCollection < ActiveRecord::Migration[7.0]
  def change
    add_reference :collections, :cover, null: true, foreign_key: { to_table: :items }
  end
end
