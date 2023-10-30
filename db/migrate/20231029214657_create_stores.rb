class CreateStores < ActiveRecord::Migration[7.0]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :domain
      t.string :slug

      t.references :admin, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
