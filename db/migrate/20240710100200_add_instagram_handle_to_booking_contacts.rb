class AddInstagramHandleToBookingContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :booking_contacts, :instagram_handle, :string
  end
end
