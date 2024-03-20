class AddEndiAuthToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :stores, :endi_auth, :text
    add_column :stores, :endi_id, :integer
  end
end
