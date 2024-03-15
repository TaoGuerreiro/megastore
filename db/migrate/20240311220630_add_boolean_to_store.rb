class AddBooleanToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :charges_enable, :boolean, default: false
    add_column :stores, :payouts_enable, :boolean, default: false
    add_column :stores, :details_submitted, :boolean, default: false
    remove_column :users, :stripe_account_id, :string
  end
end
