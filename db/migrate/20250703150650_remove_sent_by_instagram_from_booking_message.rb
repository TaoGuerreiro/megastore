class RemoveSentByInstagramFromBookingMessage < ActiveRecord::Migration[7.0]
  def change
    remove_column :booking_messages, :sent_via_instagram, :boolean
  end
end
