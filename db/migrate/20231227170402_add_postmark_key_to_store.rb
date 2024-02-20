# frozen_string_literal: true

class AddPostmarkKeyToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :postmark_key, :text
  end
end
