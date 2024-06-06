class CreateAuthors < ActiveRecord::Migration[7.0]
  def change
    create_table :authors do |t|
      t.string :nickname
      t.string :bio
      t.string :website
      t.references :store, null: false, foreign_key: true

      t.timestamps
    end
  end
end
