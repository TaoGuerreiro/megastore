# frozen_string_literal: true

class StripeCheckoutSessionService
  def call(event)
    order = Order.find_by(checkout_session_id: event.data.object.id)
    store = order.store
    order.update(status: 'paid')
    Admin::OrderMailer.payment_confirmation(order).deliver_later
    Admin::OrderMailer.new_order(order).deliver_later
    Shipment::Parcel.new(store, { order: }).create_label
    Shipment::Label.new(store, { order: }).attach_to_order
  end
end
