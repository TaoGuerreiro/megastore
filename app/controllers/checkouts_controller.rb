# frozen_string_literal: true

class CheckoutsController < ApplicationController
  before_action :set_order_intent,
                only: %i[shipping_method confirm_payment service_point undo_shipping_method undo_service_point]

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
    StripeConfigurationService.setup
    # authorize! :checkout TODO fix
  end

  def confirm_payment
    # binding.pry
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
      shipping_full_name: @order_intent.full_name,
      shipping_address: @order_intent.address_with_number,
      shipping_country: @order_intent.country,
      shipping_city: @order_intent.city,
      shipping_postal_code: @order_intent.postal_code,
      shipping_method_carrier: @shipping_method[:carrier],
      weight: @order_intent.weight,
      api_shipping_id: @order_intent.shipping_method,
      api_service_point_id: @order_intent.service_point,
      order_items: @items.map { |item| OrderItem.new(item: item[:item], quantity: item[:number]) },
      amount: @order_intent.items_price.to_f,
      shipping_cost: @order_intent.shipping_price.to_f,
      user:,
      status: 'confirmed',
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
    respond_to do |format|
      format.html { render 'checkouts/show', status: :unprocessable_entity }
      format.turbo_stream
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
    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      customer_email: @order_intent.email,
      line_items: [{
        name: @order.order_items.first.item.name,
        images: nil,
        amount: @order.total_price_cents,
        currency: 'eur',
        quantity: 1
      }],
      success_url: order_url(@order),
      cancel_url: order_url(@order)
    )

    @order.update(checkout_session_id: session.id)
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
                                         :country, :postal_code, :service_point, :items_price, :shipping_price, :need_point, :weight)
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
