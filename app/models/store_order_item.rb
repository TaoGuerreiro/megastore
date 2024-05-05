# frozen_string_literal: true

class StoreOrderItem < ApplicationRecord
  belongs_to :store_order
  belongs_to :orderable, polymorphic: true

  monetize :price_cents

  after_create_commit :create_billing_line
  after_create_commit :add_price_to_store_order

  def create_billing_line
    BillingLine.new(store_order_item: self).create
  end

  def orderable_name
    orderable.class.name
  end

  def add_price_to_store_order
    store_order.amount += price
    store_order.save
  end
end
