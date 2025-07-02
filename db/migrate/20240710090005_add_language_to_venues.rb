class AddLanguageToVenues < ActiveRecord::Migration[7.0]
  def change
    add_column :venues, :language, :string
  end
end
