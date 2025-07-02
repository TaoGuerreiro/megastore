class AddInstagramUserIdToUsers < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:users, :instagram_user_id)
      add_column :users, :instagram_user_id, :string
    end
  end
end
