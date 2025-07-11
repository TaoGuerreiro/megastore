class CreateCampagneLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :campagne_logs do |t|
      t.references :social_campagne, null: false, foreign_key: true
      t.string :event_type, null: false
      t.jsonb :payload
      t.datetime :logged_at, null: false
      t.timestamps
    end
  end
end
