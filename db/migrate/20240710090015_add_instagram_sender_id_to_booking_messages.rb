class AddInstagramSenderIdToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_messages, :instagram_sender_id, :string
  end
end
