class AddFilterableView < ActiveRecord::Migration[7.0]
  def change
    create_table :filterable_views do |t|
      t.string :title, null: false
      t.json :filters, null: false, default: []
      t.string :conjonction, null: false, default: "and"
      t.json :sort, null: false, default: {}
      t.string :model, null: false
      t.string :context_name
      t.references :owner, null: false, polymorphic: true

      t.timestamps
    end
  end
end
