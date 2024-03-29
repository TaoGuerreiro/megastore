# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :set_order_intent,
                only: %i[shipping_method confirm_payment service_point undo_shipping_method undo_service_point]
  skip_before_action :verify_authenticity_token, only: [:confirm_payment]

  def add
    manage_item_in_cart(:add)
  end

  def remove
    manage_item_in_cart(:remove)
  end

  def show
    @total = Checkout.new(session[:checkout_items]).sum
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(items_price: @total)
  end

  def confirm_payment

    @shipping_methods = session[:shipping_methods].map(&:symbolize_keys)
    @shipping_method  = find_shipping_method
    @service_points = session[:service_points].map(&:symbolize_keys) if session[:service_points]

    unless @order_intent.valid?(:finalize_order)
      respond_to do |format|
        format.html { render 'checkouts/show', status: :unprocessable_entity }
        format.turbo_stream
      end
      return
    end

    @order = Order.new(
      store: Current.store,
      order_items: @items.map { |item| OrderItem.new(item: item[:item], quantity: item[:number]) },
      amount: @order_intent.items_price.to_f,
      user:,
      status: 'confirmed',
      shipping: Shipping.new({
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
        }),
      fee: Fee.new({
          amount: @order_intent.shipping_price.to_f * Current.store.rates,
        })
      )


    if @order_intent.need_point?
      service_point = @service_points.find { |service_point| service_point[:id] == @order_intent.service_point.to_i }
      service_point_full_address = "#{service_point[:street]} #{service_point[:postal_code]}, #{service_point[:city]}"
      @order.assign_attributes(
        shipping_service_point_address: service_point_full_address,
        shipping_service_point_name: service_point[:name]
      )
    end

    if @order.save
      create_stripe_session
    else
      # Handle @order save error here
    end

  end

  private

  def find_shipping_method
    Shipment::ShippingMethod.new(Current.store,
                                 {
                                   country: @order_intent.country,
                                   postal_code: @order_intent.postal_code
                                 }).find(params[:order_intent][:shipping_method])
  end

  def create_stripe_session
    line_items = @order.order_items.map do |order_item|
      {
        price_data: {
          currency: 'eur',
          unit_amount: order_item.item.price_cents,
          product_data: {
            name: order_item.item.name,
            description: order_item.item.name,
            images: nil,
          },
        },
        quantity: order_item.quantity
      }
    end

    line_items << {
      price_data: {
        currency: 'eur',
        unit_amount: @order.shipping.cost_cents + @order.fee.amount_cents,
        product_data: {
          name: 'Logistique & livraison',
          description: 'Logistique & livraison',
          images: nil,
        },
      },
      quantity: 1
    }

    session = Stripe::Checkout::Session.create(
      {
        mode: 'payment',
        customer_email: @order_intent.email,
        line_items: line_items,
        payment_intent_data: {
          application_fee_amount: (@order.shipping.cost_cents + @order.fee.amount_cents).to_i,
        },
        success_url: order_url(@order),
        cancel_url: order_url(@order)
      },
      {
        stripe_account: Current.store.stripe_account_id
      }
    )

    @order.update(checkout_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  end


  def manage_item_in_cart(action)
    session[:checkout_items] = session[:checkout_items] || []
    @item = Item.find(params[:item_id])

    if action == :add
      session[:checkout_items] << @item.id
      notice = "#{@item.name} ajouté au panier"
    else
      session[:checkout_items].delete_at session[:checkout_items].index @item.id
      @opened = true
      notice = "#{@item.name} supprimé panier"
    end

    set_virtual_stock
    respond_to do |format|
      format.html { redirect_to item_path(@item), notice: }
      format.turbo_stream
    end
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
                                         :country, :postal_code, :service_point, :items_price, :shipping_price, :need_point, :weight, :fees_price)
  end

  def set_virtual_stock
    @item = Item.find(params[:item_id])
    cart_stock = Checkout.new(session[:checkout_items]).cart.find do |item|
                   item[:item].id == @item.id
                 end&.[](:number) || 0
    @virtual_stock = @item.stock - cart_stock
  end
end

# [
#   {:id=>371, :name=>"Colissimo Home 0-0.25kg", :carrier=>"colissimo", :min_weight=>"0.001", :max_weight=>"0.251", :service_point_input=>"none", :price=>7.09, :lead_time_hours=>48},
#   {:id=>1345, :name=>"Chrono 18 0-2kg", :carrier=>"chronopost", :min_weight=>"0.001", :max_weight=>"2.001", :service_point_input=>"none", :price=>13.64, :lead_time_hours=>48},
#   {:id=>4745, :name=>"Colis Privé Point Relais 0-0.25kg", :carrier=>"colisprive", :min_weight=>"0.001", :max_weight=>"0.251", :service_point_input=>"required", :price=>3.37, :lead_time_hours=>48},
#   {:id=>1676, :name=>"Mondial Relay Point Relais L 0-0.5kg", :carrier=>"mondial_relay", :min_weight=>"0.015", :max_weight=>"0.501", :service_point_input=>"required", :price=>3.48, :lead_time_hours=>48}
# ]
