class AddInstagramUserIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :instagram_user_id, :string
  end
end
