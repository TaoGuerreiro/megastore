class Delivery
  include ActiveModel::Model

  def initialize(order_intent_params, weight)
    @order_intent_params = order_intent_params.as_json.merge(weight: weight)
  end

  def shipping_methods
    Carrier.new(Current.store, @order_intent_params).all
  end
end
