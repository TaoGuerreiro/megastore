# frozen_string_literal: true

class OrderIntentsController < ApplicationController
  before_action :set_order_intent, only: %i[shipping_method service_point undo_shipping_method undo_service_point]

  def create
    @order_intent = OrderIntent.new(order_intent_params)
    weight = Checkout.new(session[:checkout_items]).weight
    @order_intent.weight = weight

    body = {
      country: order_intent_params[:country],
      postal_code: order_intent_params[:postal_code],
      weight:
    }
    @shipping_methods = Shipment::ShippingMethod.new(Current.store, body).all

    session[:shipping_methods] = @shipping_methods

    respond_to do |format|
      if @order_intent.valid?(:step_one)
        format.html { redirect_to checkout_path, notice: 'Order intent was successfully created.' }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def shipping_method
    @shipping_method = find_shipping_method
    @shipping_methods = session[:shipping_methods].map(&:symbolize_keys)
    @order_intent.shipping_price = @shipping_method[:price].to_f

    if @shipping_method[:service_point_input] == 'required'
      @order_intent.need_point = true
      @service_points = Shipment::ServicePoint.new(Current.store,
                                                   {
                                                     country: @order_intent.country,
                                                     postal_code: @order_intent.postal_code,
                                                     radius: 3000,
                                                     carrier: @shipping_method[:carrier]
                                                   }).all
      session[:service_points] = @service_points
    end

    respond_to do |format|
      if @order_intent.valid?(:shipping_method)
        format.html { redirect_to checkout_path, notice: 'Shipping method was successfully added.' }
      else
        format.html { render 'checkouts/show', status: :unprocessable_entity }
      end
      format.turbo_stream
    end
  end

  def service_point; end

  # def undo_shipping_method
  #   @total = Checkout.new(session[:checkout_items]).sum
  #   @items = Checkout.new(session[:checkout_items]).cart
  #   @order_intent = OrderIntent.new(items_price: @total)
  #   # StripeConfigurationService.setup

  #   respond_to do |format|
  #     format.html { redirect_to checkout_path, notice: "Shipping method was successfully removed." }
  #     format.turbo_stream
  #   end
  # end

  def undo_service_point
    @order_intent.shipping_method = nil
    @order_intent.need_point = false
    @shipping_methods = session[:shipping_methods].map(&:symbolize_keys)

    respond_to do |format|
      format.html { redirect_to checkout_path }
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

  def set_order_intent
    @items = Checkout.new(session[:checkout_items]).cart
    @order_intent = OrderIntent.new(order_intent_params)
  end

  def order_intent_params
    params.require(:order_intent).permit(:address, :city, :country, :email, :first_name, :last_name, :phone,
                                         :postal_code, :shipping_method, :shipping_price, :items_price, :need_point, :weight)
  end
end
