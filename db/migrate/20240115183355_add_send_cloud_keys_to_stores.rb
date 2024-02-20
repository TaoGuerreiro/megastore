# frozen_string_literal: true

class AddSendCloudKeysToStores < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :sendcloud_private_key, :text
    add_column :stores, :sendcloud_public_key, :text
  end
end
