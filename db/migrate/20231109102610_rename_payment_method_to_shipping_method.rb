class RenamePaymentMethodToShippingMethod < ActiveRecord::Migration[7.0]
  def change
    rename_table :payment_methods, :shipping_methods
  end
end
