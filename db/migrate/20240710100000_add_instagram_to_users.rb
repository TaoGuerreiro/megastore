class AddInstagramToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :instagram_username, :string
    add_column :users, :instagram_password, :string
  end
end
