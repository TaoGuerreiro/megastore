# frozen_string_literal: true

module Admin
  class OrdersController < ApplicationController
    layout 'admin'

    def index
      @orders = authorized_scope(Order.all)
      authorize! @orders
    end

    def show
      @order = Order.find(params[:id])
    end

    def edit
      @order = Order.find(params[:id])
      # @order.update(status: params[:status])
      # redirect_to admin_orders_path
    end

    def update
      @order = Order.find(params[:id])
      if @order.update(order_params)
        respond_to do |format|
          format.html { redirect_to admin_orders_path, notice: 'Order was successfully updated.' }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(dom_id(@order), partial: 'admin/orders/form',
                                                                      locals: { order: @order })
          end
        end
      end
    end

    def destroy
      @order = Order.find(params[:id])
      if @order.destroy && !@order.paid?
        redirect_to admin_orders_path, notice: 'Order was successfully destroyed.'
      else
        redirect_to admin_orders_path, notice: 'Order was not destroyed.'
      end
    end

    private

    def order_params
      params.require(:order).permit(:status)
    end
  end
end
