class CreateEventsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.text :data
      t.string :source
      t.string :processing_errors
      t.string :status, default: :pending

      t.timestamps
    end
  end
end
