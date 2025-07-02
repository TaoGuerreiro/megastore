class ChangeGigIdNullableInBookings < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookings, :gig_id, true
  end
end
