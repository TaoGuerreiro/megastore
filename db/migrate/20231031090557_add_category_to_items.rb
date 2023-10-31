class AddCategoryToItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :items, :category, foreign_key: true
    # Item.find_each {|item| item.category_id = 1}
  end
end
