# frozen_string_literal: true

class AddCategoryNullFalseToItem < ActiveRecord::Migration[7.0]
  def change
    change_column_null :items, :category_id, false
  end
end
