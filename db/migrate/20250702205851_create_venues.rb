class CreateVenues < ActiveRecord::Migration[7.0]
  def change
    create_table :venues do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :phone
      t.string :email
      t.integer :capacity

      t.timestamps
    end
  end
end
