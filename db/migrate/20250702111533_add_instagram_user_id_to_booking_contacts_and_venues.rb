class AddInstagramUserIdToBookingContactsAndVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :booking_contacts, :instagram_user_id, :string
    add_column :venues, :instagram_user_id, :string
  end
end
