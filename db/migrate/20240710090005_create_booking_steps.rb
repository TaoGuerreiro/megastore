class CreateBookingSteps < ActiveRecord::Migration[7.0]
  def change
    create_table :booking_steps do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :step_type
      t.text :comment

      t.timestamps
    end
  end
end
