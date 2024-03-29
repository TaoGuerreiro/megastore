class RenameCollectionTypeToFormatOnItems < ActiveRecord::Migration[7.0]
  def change
    rename_column :items, :collection_type, :format
  end
end
