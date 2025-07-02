class AddInstagramTimestampToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_messages, :instagram_timestamp, :datetime
  end
end
