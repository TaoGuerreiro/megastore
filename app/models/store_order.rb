# frozen_string_literal: true

class StoreOrder < ApplicationRecord
  belongs_to :store
  has_many :store_order_items, dependent: :destroy
  has_many :fees, through: :store_order_items, source: :orderable, source_type: "Fee"
  has_many :shippings, through: :store_order_items, source: :orderable, source_type: "Shipping"
  has_many :subscriptions, through: :store_order_items, source: :orderable, source_type: "Subscription"

  monetize :amount_cents

  after_create_commit :create_billing

  def create_billing
    Billing.new(store_order: self).create
  end
end
