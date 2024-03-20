class StoreOrderItem < ApplicationRecord
  belongs_to :store_order
  belongs_to :orderable, polymorphic: true

  monetize :price_cents

  after_create_commit :create_billing_line

  def create_billing_line
    BillingLine.create(store_order_item: self, amount: amount)
  end
end
