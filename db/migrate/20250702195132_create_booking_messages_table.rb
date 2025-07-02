class CreateBookingMessagesTable < ActiveRecord::Migration[7.0]
  def change
    unless table_exists?(:booking_messages)
      create_table :booking_messages do |t|
        t.references :booking, null: false, foreign_key: true
        t.references :user, null: false, foreign_key: true
        t.text :text, null: false
        t.boolean :sent_via_instagram, default: false, null: false
        t.timestamps
      end
    end
  end
end
