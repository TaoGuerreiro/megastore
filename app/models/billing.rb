class Billing
  include ActiveModel::Model

  def initialize(store_order:, amount:)
    @store_order = store_order
    @amount = amount
  end

  def create
    EndiServices::NewInvoice.new(@store_order, Current.store).call
  end
end
