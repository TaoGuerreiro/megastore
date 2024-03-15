class AddStripeAccountIdToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :stripe_account_id, :string
  end
end
