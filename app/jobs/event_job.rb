# frozen_string_literal: true

class EventJob < ApplicationJob
  queue_as :default

  def perform(event)
    event.update(status: "processing")
    case event.source
    when "stripe"
      handle_stripe_event(event)
    when "stripe_subscription"
      handle_stripe_subscription_event(event)
    when "sendcloud"
      handle_sendcloud_event(event)
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
    Shipment::Parcel.new(store, { order: }).create_label
    Shipment::Label.new(store, { order: }).attach_to_order
  end

  def update_store_order(order)
    store_order = StoreOrder.find_or_create_by(store: order.store, status: "pending") do |store_order|
      store_order.store_order_items.new(orderable: order.fee, price: order.fee.amount)
      store_order.store_order_items.new(orderable: order.shipping, price: order.shipping.cost)
      store_order.date = Time.current
    end

    add_items_to_store_order(store_order, order)
    store_order.save
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

# store = Store.first
# order = Order.last

# {"action"=>"parcel_status_changed",
#  "parcel"=>
#   {"id"=>364069982,
#    "address"=>"26 bis rue",
#    "contract"=>nil,
#    "address_2"=>"aristide briand",
#    "address_divided"=>{"street"=>"bis rue", "house_number"=>"26"},
#    "city"=>"saint sébastien sur loire",
#    "company_name"=>"",
#    "country"=>{"iso_2"=>"FR", "iso_3"=>"FRA", "name"=>"France"},
#    "data"=>{},
#    "date_created"=>"03-04-2024 16:51:28",
#    "email"=>"zd.guilbaud@gmail.com",
#    "name"=>"GUILBAUD Florent",
#    "postal_code"=>"44230",
#    "reference"=>"0",
#    "shipment"=>{"id"=>1345, "name"=>"Chrono 18 0-2kg"},
#    "status"=>{"id"=>1001, "message"=>"Being announced"},
#    "to_service_point"=>nil,
#    "telephone"=>"+33674236080",
#    "tracking_number"=>"",
#    "weight"=>"0.143",
#    "label"=>{"normal_printer"=>nil, "label_printer"=>nil},
#    "customs_declaration"=>{},
#    "order_number"=>"10",
#    "insured_value"=>0.0,
#    "total_insured_value"=>0.0,
#    "to_state"=>nil,
#    "customs_invoice_nr"=>"",
#    "customs_shipment_type"=>nil,
#    "parcel_items"=>[],
#    "documents"=>[],
#    "type"=>nil,
#    "shipment_uuid"=>nil,
#    "shipping_method"=>1345,
#    "shipping_method_checkout_name"=>"Stripe",
#    "external_order_id"=>"364069982",
#    "external_shipment_id"=>"",
#    "external_reference"=>nil,
#    "is_return"=>false,
#    "note"=>"",
#    "to_post_number"=>"",
#    "total_order_value"=>nil,
#    "total_order_value_currency"=>nil,
#    "carrier"=>{"code"=>"chronopost", "name"=>"Chronopost", "servicepoints_carrier_code"=>"chronopost"},
#    "tracking_url"=>nil,
#    "date_updated"=>"03-04-2024 16:51:28",
#    "date_announced"=>nil,
#    "colli_tracking_number"=>nil,
#    "colli_uuid"=>"30c857c1-d679-4a93-9041-7265cb098925",
#    "collo_nr"=>0,
#    "collo_count"=>1,
#    "awb_tracking_number"=>nil,
#    "box_number"=>nil,
#    "length"=>"50.00",
#    "width"=>"50.00",
#    "height"=>"50.00",
#    "track_trace_notifications"=>true,
#    "from_country"=>{"iso_2"=>"FR", "iso_3"=>"FRA", "name"=>"France"},
#    "from_postal_code"=>"44230",
#    "date_shipped"=>nil,
#    "house_number"=>"26",
#    "suppressed_statuses"=>[],
#    "should_send_feedback"=>true,
#    "source"=>"api_v2:bucket",
#    "extra_data"=>{}},
#  "timestamp"=>1712163088943,
#  "carrier_status_change_timestamp"=>1712163088908}

# {"action"=>"parcel_status_changed",
#  "parcel"=>
#   {"id"=>364069982,
#    "address"=>"26 bis rue",
#    "contract"=>nil,
#    "address_2"=>"aristide briand",
#    "address_divided"=>{"street"=>"bis rue", "house_number"=>"26"},
#    "city"=>"saint sébastien sur loire",
#    "company_name"=>"",
#    "country"=>{"iso_2"=>"FR", "iso_3"=>"FRA", "name"=>"France"},
#    "data"=>{},
#    "date_created"=>"03-04-2024 16:51:28",
#    "email"=>"zd.guilbaud@gmail.com",
#    "name"=>"GUILBAUD Florent",
#    "postal_code"=>"44230",
#    "reference"=>"0",
#    "shipment"=>{"id"=>1345, "name"=>"Chrono 18 0-2kg"},
#    "status"=>{"id"=>1001, "message"=>"Being announced"},
#    "to_service_point"=>nil,
#    "telephone"=>"+33674236080",
#    "tracking_number"=>"",
#    "weight"=>"0.143",
#    "label"=>{"normal_printer"=>nil, "label_printer"=>nil},
#    "customs_declaration"=>{},
#    "order_number"=>"10",
#    "insured_value"=>0.0,
#    "total_insured_value"=>0.0,
#    "to_state"=>nil,
#    "customs_invoice_nr"=>"",
#    "customs_shipment_type"=>nil,
#    "parcel_items"=>[],
#    "documents"=>[],
#    "type"=>nil,
#    "shipment_uuid"=>nil,
#    "shipping_method"=>1345,
#    "shipping_method_checkout_name"=>"Stripe",
#    "external_order_id"=>"364069982",
#    "external_shipment_id"=>"",
#    "external_reference"=>nil,
#    "is_return"=>false,
#    "note"=>"",
#    "to_post_number"=>"",
#    "total_order_value"=>nil,
#    "total_order_value_currency"=>nil,
#    "carrier"=>{"code"=>"chronopost", "name"=>"Chronopost", "servicepoints_carrier_code"=>"chronopost"},
#    "tracking_url"=>nil,
#    "date_updated"=>"03-04-2024 16:51:28",
#    "date_announced"=>nil,
#    "colli_tracking_number"=>nil,
#    "colli_uuid"=>"30c857c1-d679-4a93-9041-7265cb098925",
#    "collo_nr"=>0,
#    "collo_count"=>1,
#    "awb_tracking_number"=>nil,
#    "box_number"=>nil,
#    "length"=>"50.00",
#    "width"=>"50.00",
#    "height"=>"50.00",
#    "track_trace_notifications"=>true,
#    "from_country"=>{"iso_2"=>"FR", "iso_3"=>"FRA", "name"=>"France"},
#    "from_postal_code"=>"44230",
#    "date_shipped"=>nil,
#    "house_number"=>"26",
#    "suppressed_statuses"=>[],
#    "should_send_feedback"=>true,
#    "source"=>"api_v2:bucket",
#    "extra_data"=>{}},
#  "timestamp"=>1712163088943,
#  "carrier_status_change_timestamp"=>1712163088908}
