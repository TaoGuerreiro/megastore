class RemoveKeysFromStores < ActiveRecord::Migration[7.0]
  def change
    remove_column :stores, :stripe_publishable_key, :string
    remove_column :stores, :stripe_secret_key, :string
    remove_column :stores, :stripe_webhook_secret_key, :string
  end
end
