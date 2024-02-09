class OrderIntentsController < ApplicationController
  def create
    @order_intent = OrderIntent.new(order_intent_params)
    weight = Checkout.new(session[:checkout_items]).weight
    @order_intent.weight = weight
    @shipping_methods = Shipment::ShippingMethod.new(Current.store,
      {
        country: order_intent_params[:country],
        postal_code: order_intent_params[:postal_code],
        weight:
      }).all

    session[:shipping_methods] = @shipping_methods

    respond_to do |format|
      if @order_intent.valid?(:basic_informations_input)
        format.html { redirect_to checkout_path, notice: "Order intent was successfully created." }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  private

  def order_intent_params
    params.require(:order_intent).permit(:address, :city, :country, :email, :first_name, :last_name, :phone, :postal_code, :shipping_method, :items_price, :need_point, :weight)
  end
end
