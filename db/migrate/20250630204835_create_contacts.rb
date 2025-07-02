class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_contacts do |t|
      t.string :name
      t.string :email
      t.string :phone
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.text :notes

      t.timestamps
    end
  end
end
