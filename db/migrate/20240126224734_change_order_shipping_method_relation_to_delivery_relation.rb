class ChangeOrderShippingMethodRelationToDeliveryRelation < ActiveRecord::Migration[7.0]
  def change
    rename_column :orders, :shipping_method_id, :delivery_method_id
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
