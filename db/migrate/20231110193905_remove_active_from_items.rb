class RemoveActiveFromItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :items, :active, :boolean
  end
end
