# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :set_order_intent, only: %i[confirm_payment]
  before_action :set_service_points, only: %i[confirm_payment]
  before_action :set_shipping_methods, only: %i[confirm_payment]
  before_action :set_store, only: %i[confirm_payment]
  skip_before_action :verify_authenticity_token, only: [:confirm_payment]

  def show
    @total = Checkout.new(session[:checkout_items]).sum
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(items_price: @total)
  end

  def confirm_payment
    @shipping_method = find_shipping_method

    if @order_intent.valid?(:finalize_order)
      finalize_order
    else
      respond_to do |format|
        format.html { render "checkouts/show", status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  private

  def set_store
    @store = Current.store
  end

  def finalize_order
    @order = create_order
    set_points if @order_intent.need_point?
    @order.save
    create_stripe_session
  end

  def set_shipping_methods
    @shipping_methods = session[:shipping_methods].map(&:symbolize_keys)
  end

  def set_service_points
    @service_points = session[:service_points].map(&:symbolize_keys) if session[:service_points]
  end

  def set_points
    service_points = @service_points.find { |service_point| service_point[:id] == @order_intent.service_point.to_i }
    service_point_full_address = "#{service_points[:street]} #{service_points[:postal_code]}, #{service_points[:city]}"
    @order.assign_attributes(
      shipping_service_point_address: service_point_full_address,
      shipping_service_point_name: service_points[:name]
    )
  end

  def create_order
    Order.new(
      fee:,
      user:,
      shipping:,
      discount:,
      store: @store,
      order_items: @items.map { |item| OrderItem.new(item: item[:item], quantity: item[:number]) },
      amount: @order_intent.items_price.to_f,
      status: "confirmed"
    )
  end

  def fee
    Fee.new({
              amount: @order_intent.shipping_price.to_f * @store.rates
            })
  end

  def discount
    Discount.new({
                   amount: @order_intent.discount.to_f,
                   percentage: @order_intent.discount_percentage.to_f
                 })
  end

  def find_shipping_method
    Shipments::ShippingMethod.new(@store,
                                  {
                                    country: @order_intent.country,
                                    postal_code: @order_intent.postal_code
                                  }).find(params[:order_intent][:shipping_method])
  end

  def shipping
    Shipping.new({
                   cost: @order_intent.shipping_price.to_f,
                   address_first_line: @order_intent.address_first_line,
                   address_second_line: @order_intent.address_second_line,
                   street_number: @order_intent.street_number,
                   city: @order_intent.city,
                   country: @order_intent.country,
                   postal_code: @order_intent.postal_code,
                   full_name: @order_intent.full_name,
                   method_carrier: @shipping_method[:carrier],
                   weight: @order_intent.weight,
                   api_shipping_id: @order_intent.shipping_method,
                   api_service_point_id: @order_intent.service_point
                 })
  end

  def create_line_items
    @order.order_items.map do |order_item|
      {
        price_data: {
          currency: "eur",
          unit_amount: (order_item.item.price_cents * (1 - @order.discount.percentage.to_f)).to_i,
          product_data: {
            name: order_item.item.name,
            description: "#{order_item.item.name} avec remise de #{@order.discount.percentage.to_f * 100}%",
            images: nil
          }
        },
        quantity: order_item.quantity
      }
    end
  end

  def extra_cost
    {
      price_data: {
        currency: "eur",
        unit_amount: @order.shipping.cost_cents + @order.fee.amount_cents,
        product_data: {
          name: "Logistique & livraison",
          description: "Logistique & livraison",
          images: nil
        }
      },
      quantity: 1
    }
  end

  def stripe_session
    Stripe::Checkout::Session.create(
      {
        mode: "payment",
        customer_email: @order_intent.email,
        line_items: @line_items,
        payment_intent_data:
        {
          application_fee_amount: (@order.shipping.cost_cents + @order.fee.amount_cents).to_i
        },
        success_url: order_url(@order),
        cancel_url: order_url(@order)
      },
      {
        stripe_account: @store.stripe_account_id
      }
    )
  end

  def create_stripe_session
    @line_items = create_line_items
    @line_items << extra_cost
    session = stripe_session
    @order.update(checkout_session_id: session.id)
    redirect_to session.url, allow_other_host: true
  end

  def user
    User.find_or_create_by(email: order_intent_params[:email]) do |user|
      user.first_name = order_intent_params[:first_name]
      user.last_name = order_intent_params[:last_name]
      user.phone = order_intent_params[:phone]
      user.password = SecureRandom.hex(10)
    end
  end

  def set_order_intent
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(order_intent_params)
  end

  def order_intent_params
    return {} unless params[:order_intent]

    params.require(:order_intent).permit(:email, :first_name, :last_name, :address, :phone, :shipping_method, :city,
                                         :country, :postal_code, :service_point, :items_price, :shipping_price,
                                         :need_point, :weight, :fees_price, :discount, :discount_percentage)
  end
end
