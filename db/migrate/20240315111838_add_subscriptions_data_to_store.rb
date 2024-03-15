class AddSubscriptionsDataToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :stripe_subscription_id, :string
    add_column :stores, :subscription_status, :string, null: false, default: 'pending'
    add_column :stores, :stripe_checkout_session_id, :string
    add_index :stores, :stripe_subscription_id, unique: true
  end

end
