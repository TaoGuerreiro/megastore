class CreateSocialTargets < ActiveRecord::Migration[7.0]
  def change
    create_table :social_targets do |t|
      t.string :name, null: false
      t.string :kind, null: false
      t.string :cursor
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :social_targets, [:user_id, :name, :kind], unique: true
  end
end
