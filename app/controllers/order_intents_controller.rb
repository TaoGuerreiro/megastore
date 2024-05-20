# frozen_string_literal: true

class OrderIntentsController < ApplicationController
  before_action :set_order_intent, only: %i[shipping_method service_point undo_service_point]
  before_action :shipping_methods_from_session, only: %i[shipping_method undo_service_point]
  before_action :set_shipping_method, only: %i[shipping_method]

  def create
    @order_intent = OrderIntent.new(order_intent_params)
    set_shipping_methods

    respond_to do |format|
      if @order_intent.valid?(:step_one)
        format.html { redirect_to checkout_path, status: :see_other, notice: t(".success") }
      else
        format.html { render :new, status: :unprocessable_entity, notice: t(".error") }
      end
      format.turbo_stream
    end
  end

  def shipping_method
    calculate_shipping_and_fees_price
    fetch_services_points

    respond_to do |format|
      if @order_intent.valid?(:shipping_method)
        format.html { redirect_to checkout_path, status: :see_other, notice: t(".success") }
      else
        format.html { render "checkouts/show", status: :unprocessable_entity, notice: t(".error") }
      end
      format.turbo_stream
    end
  end

  def service_point
    respond_to do |format|
      format.html { redirect_to checkout_path, status: :see_other, notice: t(".success") }
      format.turbo_stream
    end
  end

  def undo_service_point
    @order_intent.shipping_method = nil
    @order_intent.need_point = false

    respond_to do |format|
      format.html { redirect_to checkout_path }
      format.turbo_stream
    end
  end

  private

  def calculate_shipping_and_fees_price
    @order_intent.shipping_price = @shipping_method[:price].to_f * 1.2
    @order_intent.fees_price = @order_intent.shipping_price * Current.store.rates
  end

  def set_shipping_method
    @shipping_method = find_shipping_method
  end

  def fetch_services_points
    return unless @shipping_method[:service_point_input] == "required"

    @order_intent.need_point = true
    @service_points = fetch_service_points
    session[:service_points] = @service_points
  end

  def shipping_methods_from_session
    @shipping_methods = session[:shipping_methods].map(&:symbolize_keys)
  end

  def fetch_service_points
    Shipments::ServicePoint.new(Current.store,
                                {
                                  country: @order_intent.country,
                                  postal_code: @order_intent.postal_code,
                                  radius: 3000,
                                  carrier: @shipping_method[:carrier]
                                }).all
  end

  def set_shipping_methods
    @weight = Checkout.new(session[:checkout_items]).weight
    @order_intent.weight = @weight
    @shipping_methods = Shipments::ShippingMethod.new(Current.store, body).all
    session[:shipping_methods] = @shipping_methods
  end

  def body
    {
      country: order_intent_params[:country],
      postal_code: order_intent_params[:postal_code],
      weight: @weight
    }
  end

  def find_shipping_method
    Shipments::ShippingMethod.new(Current.store,
                                  {
                                    country: @order_intent.country,
                                    postal_code: @order_intent.postal_code
                                  }).find(params[:order_intent][:shipping_method])
  end

  def set_order_intent
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(order_intent_params)
  end

  def order_intent_params
    return {} unless params[:order_intent]

    params.require(:order_intent).permit(:email, :first_name, :last_name, :address, :phone, :shipping_method, :city,
                                         :country, :postal_code, :service_point, :items_price, :shipping_price,
                                         :need_point, :weight, :fees_price)
  end
end
