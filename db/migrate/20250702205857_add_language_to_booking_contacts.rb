class AddLanguageToBookingContacts < ActiveRecord::Migration[7.0]
  def change
    add_column :booking_contacts, :language, :string
  end
end
