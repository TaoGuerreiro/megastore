class Billing
  include ActiveModel::Model

  def initialize(store_order:)
    @store_order = store_order
  end

  def create
    EndiServices::NewInvoice.new(@store_order, @store_order.store).call
  end
end
