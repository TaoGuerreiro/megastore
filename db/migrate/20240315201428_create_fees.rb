class CreateFees < ActiveRecord::Migration[7.0]
  def change
    create_table :fees do |t|
      t.references :order, null: false, foreign_key: true
      t.monetize :amount

      t.timestamps
    end
  end
end
