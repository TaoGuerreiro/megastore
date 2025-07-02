class CreateBookingMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :booking_messages do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :text, null: false
      t.boolean :sent_via_instagram, default: false, null: false
      t.timestamps
    end
  end
end
