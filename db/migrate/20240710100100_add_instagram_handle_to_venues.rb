class AddInstagramHandleToVenues < ActiveRecord::Migration[6.1]
  def change
    add_column :venues, :instagram_handle, :string
  end
end
