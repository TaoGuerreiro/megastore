# frozen_string_literal: true

class AddStoreReferenceToSpecifications < ActiveRecord::Migration[7.0]
  def change
    add_reference :specifications, :store, null: false, foreign_key: true
  end
end
