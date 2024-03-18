class Fee < ApplicationRecord
  has_many :store_order_items, as: :orderable
  has_one :store_order, through: :store_order_items
  belongs_to :order
  monetize :amount_cents
end
