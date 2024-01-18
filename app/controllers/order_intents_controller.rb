class OrderIntentsController < ApplicationController
  def create
    @order_intent = OrderIntent.new(order_intent_params)

    respond_to do |format|
      if @order_intent.valid?
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
    params.require(:order_intent).permit(:address, :city, :country, :email, :first_name, :last_name, :phone, :postal_code, :shipping_method)
  end
end
