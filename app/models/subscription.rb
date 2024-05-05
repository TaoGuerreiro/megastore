# frozen_string_literal: true

class Subscription < ApplicationRecord
  has_many :store_order_items, as: :orderable
  has_one :store_order, through: :store_order_items
  monetize :price_cents
end
