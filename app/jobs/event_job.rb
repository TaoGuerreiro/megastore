# frozen_string_literal: true

class EventJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.update(status: "processing")
    case event.source
    when "stripe" then handle_stripe_event(event)
    when "stripe_subscription" then handle_stripe_subscription_event(event)
    when "sendcloud" then handle_sendcloud_event(event)
    end
    event.update(status: :processed)
  rescue StandardError => e
    event.update(processing_errors: e.to_s, status: :failed)
  end

  def handle_sendcloud_event(raw_event)
    event = JSON.parse(raw_event.data)
    case event["action"]
    when "parcel_status_changed"
      handle_parcel_status_change(event)
    end
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

  def handle_parcel_status_change(event)
    shipping = Shipping.find_by(parcel_id: event["parcel"]["id"])
    shipping.update(status: event["parcel"]["status"]["message"])
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

  def handle_session_completed(event)
    order = Order.find_by(checkout_session_id: event.data.object.id)
    return if order.status == "paid"

    order.update(status: "paid")

    send_emails(order)
    create_shipment(order)
    update_store_order(order)
  end

  private

  def send_emails(order)
    Admin::OrderMailer.payment_confirmation(order).deliver_later
    Admin::OrderMailer.new_order(order).deliver_later
  end

  def create_shipment(order)
    store = order.store
    Shipments::Parcel.new(store, { order: }).create_label
    Shipments::Label.new(store, { order: }).attach_to_order
  end

  def update_store_order(order)
    # binding.pry

    new_store_order = StoreOrder.find_or_create_by(store: order.store, status: "pending") do |store_order|
      store_order.store_order_items.new(orderable: order.fee, price: order.fee.amount)
      store_order.store_order_items.new(orderable: order.shipping, price: order.shipping.cost)
      store_order.date = Time.current
    end

    add_items_to_store_order(new_store_order, order)
    new_store_order.save
  end

  def add_items_to_store_order(store_order, order)
    if store_order.fees.exclude?(order.fee)
      store_order.store_order_items.new(orderable: order.fee,
                                        price: order.fee.amount)
    end
    return unless store_order.shippings.exclude?(order.shipping)

    store_order.store_order_items.new(orderable: order.shipping,
                                      price: order.shipping.cost)
  end
end
