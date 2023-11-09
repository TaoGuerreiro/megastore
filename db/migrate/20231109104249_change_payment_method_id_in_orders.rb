class ChangePaymentMethodIdInOrders < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :payment_method_id, :shipping_method_id
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
