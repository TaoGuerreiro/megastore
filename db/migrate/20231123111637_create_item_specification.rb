class CreateItemSpecification < ActiveRecord::Migration[7.0]
  def change
    create_table :item_specifications do |t|
      t.references :item, null: false, foreign_key: true
      t.references :specification, null: false, foreign_key: true

      t.timestamps
    end
  end
end
