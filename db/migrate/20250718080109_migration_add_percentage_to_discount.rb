class MigrationAddPercentageToDiscount < ActiveRecord::Migration[7.0]
  def change
    add_column :discounts, :percentage, :float
  end
end
