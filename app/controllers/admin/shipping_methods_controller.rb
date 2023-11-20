module Admin
  class ShippingMethodsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_shipping_method, only: %i[edit update destroy]
    before_action :set_store, only: %i[new create edit update destroy]

    layout "admin"

    def new
      @shipping_method = Current.store.shipping_methods.build
      authorize! @shipping_method
    end

    def create
      @shipping_method = Current.store.shipping_methods.build(shipping_method_params)
      authorize! @shipping_method

      if @shipping_method.save
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: "Shipping method was successfully created." }
          format.turbo_stream
        end
      else
        render :new
      end
    end

    def edit; end

    def update
      if @shipping_method.update(shipping_method_params)
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: "Shipping method was successfully updated." }
          format.turbo_stream
        end
      else
        render :edit
      end
    end

    def destroy
      if @shipping_method.destroy
        flash[:notice] = "Shipping method was successfully destroyed."
        respond_to do |format|
          format.html { redirect_to admin_store_path, notice: "Shipping method was successfully destroyed." }
          format.turbo_stream
        end
      else
        redirect_to admin_store_path, alert: "Shipping method was not destroyed."
      end
    end

    private

    def set_shipping_method
      @shipping_method = Current.store.shipping_methods.find(params[:id])
      authorize! @shipping_method
    end

    def set_store
      @store = Current.store
    end

    def shipping_method_params
      params.require(:shipping_method).permit(:name, :description, :price, :max_weight, :service_name)
    end
  end
end
