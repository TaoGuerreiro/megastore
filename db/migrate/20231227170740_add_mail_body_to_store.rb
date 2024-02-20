# frozen_string_literal: true

class AddMailBodyToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :mail_body, :text
  end
end
