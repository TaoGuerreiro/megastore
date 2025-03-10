class AddSubNameToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :sub_name, :string
  end
end
