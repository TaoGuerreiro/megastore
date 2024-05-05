# frozen_string_literal: true

class BillingLine
  include ActiveModel::Model

  def initialize(store_order_item:)
    @store_order_item = store_order_item
  end

  def create
    EndiServices::AddBillLine.new(@store_order_item, @store_order_item.store_order.store).call
  end
end
