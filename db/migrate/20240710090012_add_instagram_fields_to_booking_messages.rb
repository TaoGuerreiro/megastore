class AddInstagramFieldsToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_messages, :instagram_message_id, :string
    add_column :booking_messages, :instagram_sender_username, :string
    add_column :booking_messages, :instagram_sender_full_name, :string
    add_column :booking_messages, :is_incoming, :boolean
  end
end
