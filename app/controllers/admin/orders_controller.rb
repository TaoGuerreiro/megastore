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
      if !@order.paid? && @order.destroy
        redirect_to admin_orders_path, status: :see_other, notice: t(".success")
      else
        flash.now[:notice] = t(".error")
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
      authorize! @order, with: Admin::OrderPolicy
    end
  end
end
