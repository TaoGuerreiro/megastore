class AddVenueIdToBookings < ActiveRecord::Migration[7.0]
  def change
    add_reference :bookings, :venue, null: true, foreign_key: true
  end
end
