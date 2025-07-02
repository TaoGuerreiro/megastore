class AddStatusToBookingMessages < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:booking_messages, :status)
      add_column :booking_messages, :status, :string, default: 'pending', null: false
    end

    unless index_exists?(:booking_messages, :status)
      add_index :booking_messages, :status
    end
  end
end
