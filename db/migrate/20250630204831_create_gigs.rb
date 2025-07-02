class CreateGigs < ActiveRecord::Migration[7.0]
  def change
    create_table :gigs do |t|
      t.references :venue, null: false, foreign_key: true
      t.date :date
      t.time :time
      t.interval :duration
      t.decimal :price
      t.text :description

      t.timestamps
    end
  end
end
