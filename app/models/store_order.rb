class StoreOrder < ApplicationRecord
  belongs_to :store
  has_many :store_order_items
  has_many :fees, through: :store_order_items, source: :orderable, source_type: 'Fee'
  has_many :shippings, through: :store_order_items, source: :orderable, source_type: 'Shipping'
  has_many :subscriptions, through: :store_order_items, source: :orderable, source_type: 'Subscription'
end
