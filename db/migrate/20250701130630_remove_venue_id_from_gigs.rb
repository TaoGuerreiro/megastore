class RemoveVenueIdFromGigs < ActiveRecord::Migration[7.0]
  def change
    remove_reference :gigs, :venue, foreign_key: true
  end
end
