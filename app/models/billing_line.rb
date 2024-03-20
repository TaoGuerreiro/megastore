class BillingLine
  include ActiveModel::Model

  def initialize(store_order_item:, amount:)
    @store_order = store_order
    @amount = amount
  end

  def create
    EndiServices::AddBillLine.new(@store_order_item, Current.store).call
  end
end
