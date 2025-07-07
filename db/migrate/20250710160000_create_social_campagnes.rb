class CreateSocialCampagnes < ActiveRecord::Migration[7.0]
  def change
    create_table :social_campagnes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.string :name
      t.timestamps
    end
  end
end
