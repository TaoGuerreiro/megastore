class AddStatusToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_messages, :status, :string, default: 'pending', null: false
    add_index :booking_messages, :status
  end
end
