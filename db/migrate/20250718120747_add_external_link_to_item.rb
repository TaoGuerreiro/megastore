class AddExternalLinkToItem < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :external_link, :string
  end
end
