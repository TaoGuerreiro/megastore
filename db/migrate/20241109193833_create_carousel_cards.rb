class CreateCarouselCards < ActiveRecord::Migration[7.0]
  def change
    create_table :carousel_cards do |t|
      t.string :title
      t.string :url
      t.integer :position_x
      t.integer :position_y

      t.timestamps
    end
  end
end
