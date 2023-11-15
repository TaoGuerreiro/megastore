class StripeCheckoutSessionService
  def call(event)
    order = Order.find_by(checkout_session_id: event.data.object.id)
    order.update(status: 'paid')
    Admin::OrderMailer.payment_confirmation(order).deliver_later
  end
end
