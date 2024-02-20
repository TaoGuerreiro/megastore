# frozen_string_literal: true

#   @id = method_hash["id"]
#   @name = method_hash["name"]
#   @carrier = method_hash["carrier"]
#   @min_weight = method_hash["min_weight"]
#   @max_weight = method_hash["max_weight"]
#   @service_point_input = method_hash["service_point_input"]
#   @price = method_hash["countries"][0]["price"]
#   @lead_time_hours = method_hash["countries"][0]["lead_time_hours"]

# create_table "shipping_methods", force: :cascade do |t|
#   t.string "name"
#   t.string "description"
#   t.integer "price_cents", default: 0, null: false
#   t.string "price_currency", default: "EUR", null: false
#   t.bigint "store_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.integer "max_weight"
#   t.string "service_name"
#   t.index ["store_id"], name: "index_shipping_methods_on_store_id"
# end

class ChangingShippingMethodsFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :shipping_methods, :description
    remove_column :shipping_methods, :store_id
    add_column :shipping_methods, :carrier, :string
    add_column :shipping_methods, :min_weight, :float
    add_column :shipping_methods, :service_point_input, :string
    add_column :shipping_methods, :lead_time_hours, :integer
    add_column :shipping_methods, :shipping_method_api_id, :integer
    rename_table :shipping_methods, :delivery_methods
  end
end
