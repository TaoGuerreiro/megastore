class StoreOrderItem < ApplicationRecord
  belongs_to :store_order
  belongs_to :orderable, polymorphic: true
end