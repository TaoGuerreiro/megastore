class ChangeBookingContactIdNullableInBookings < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bookings, :booking_contact_id, true
  end
end
