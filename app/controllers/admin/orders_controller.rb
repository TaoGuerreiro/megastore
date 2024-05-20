# frozen_string_literal: true

module Admin
  class OrdersController < AdminController
    before_action :set_order, only: %i[show destroy]
    def index
      @orders = authorized_scope(Order.all)
      @orders = @orders.search_by_client(params[:search]) if params[:search].present?

      authorize! @orders
    end

    def show; end

    def destroy
      if @order.destroy && !@order.paid?
        redirect_to admin_orders_path, status: :see_other, notice: t(".success")
      else
        redirect_to admin_orders_path, notice: t(".error")
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
      authorize! @order
    end

    def order_params
      params.require(:order).permit(:status)
    end
  end
end
