class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.date :date
      t.monetize :price

      t.timestamps
    end
  end
end
