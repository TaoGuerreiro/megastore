# frozen_string_literal: true

class AddStripeKeyToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :stripe_publishable_key, :text
    add_column :stores, :stripe_secret_key, :text
    add_column :stores, :stripe_webhook_secret_key, :text
  end
end
