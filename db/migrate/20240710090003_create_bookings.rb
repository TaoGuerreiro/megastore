class CreateBookings < ActiveRecord::Migration[7.0]
  def change
    create_table :bookings do |t|
      t.references :gig, null: false, foreign_key: true
      t.references :booking_contact, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end
