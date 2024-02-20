# frozen_string_literal: true

class CreateSpecification < ActiveRecord::Migration[7.0]
  def change
    create_table :specifications do |t|
      t.string :name

      t.timestamps
    end
  end
end
