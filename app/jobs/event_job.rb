class EventJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.update(status: "processing")
    if event.source == "stripe"
      handle_stripe_event(event)
    elsif event.source == "stripe_subscription"
      handle_stripe_subscription_event(event)
    end
    event.update(status: :processed)
  rescue => e
    event.update(processing_errors: e.to_s, status: :failed)

  end

  def handle_stripe_event(raw_event)
    event = Stripe::Event.construct_from(JSON.parse(raw_event.data))
    case event.type
    when "account.updated"
      handle_account_updated(event)
    when "checkout.session.completed"
      handle_session_completed(event)
    end
  end

  def handle_stripe_subscription_event(raw_event)
    event = Stripe::Event.construct_from(JSON.parse(raw_event.data))
    case event.type
    when "checkout.session.completed"
      handle_subscription_session_completed(event)
    when "customer.subscription.updated", "customer.subscription.canceled", "customer.subscription.deleted"
      handle_subscription_updated(event)
    end
  end

  def handle_subscription_updated(event)
    session = event.data.object
    store = Store.find_by(stripe_subscription_id: session.id)
    subscription = Stripe::Subscription.retrieve(session.id)
    store.update(
      subscription_status: subscription.status
    )
  end

  def handle_account_updated(event)
    store = Store.find_by(stripe_account_id: event.account)
    store.update(
      charges_enable: event.data.object.charges_enabled,
      payouts_enable: event.data.object.payouts_enabled,
      details_submitted: event.data.object.details_submitted
    )
  end

  def handle_session_completed(event)
    order = Order.find_by(checkout_session_id: event.data.object.id)
    return if order.status == "paid"

    store = order.store
    order.update(status: 'paid')
    Admin::OrderMailer.payment_confirmation(order).deliver_later
    Admin::OrderMailer.new_order(order).deliver_later
    Shipment::Parcel.new(store, { order: }).create_label
    Shipment::Label.new(store, { order: }).attach_to_order

    # StoreOrder.new({
    #   fees: [order.fee],
    #   shippings: [order.shipping],
    #   store: store,
    #   amount: order.logistic_and_shipping_price,
    #   date: Time.current
    # })
  end

  def handle_subscription_session_completed(event)
    session = event.data.object
    store = Store.find_by(stripe_checkout_session_id: session.id)
    subscription = Stripe::Subscription.retrieve(session.subscription)
    store.update(
      subscription_status: subscription.status,
      stripe_checkout_session_id: session.id,
      stripe_subscription_id: session.subscription
    )
  end
end
