class AddInstagramColumnsToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:booking_messages, :instagram_message_id)
      add_column :booking_messages, :instagram_message_id, :string
    end

    unless column_exists?(:booking_messages, :instagram_sender_username)
      add_column :booking_messages, :instagram_sender_username, :string
    end

    unless column_exists?(:booking_messages, :instagram_sender_full_name)
      add_column :booking_messages, :instagram_sender_full_name, :string
    end

    unless column_exists?(:booking_messages, :instagram_sender_id)
      add_column :booking_messages, :instagram_sender_id, :string
    end

    unless column_exists?(:booking_messages, :instagram_timestamp)
      add_column :booking_messages, :instagram_timestamp, :datetime
    end
  end
end
