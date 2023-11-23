module Admin
  class StoresController < ApplicationController
    before_action :authenticate_user!
    layout "admin"

    def show
      @store = Current.store
      authorize! @store
      @categories = Current.store.categories
      @shipping_methods = Current.store.shipping_methods
      @specifications = Current.store.specifications
    end

    def edit
      @store = Current.store
      authorize! @store
    end

    def update
      @store = Store.find(params[:id])
      authorize! @store
      if @store.update(store_params)
        respond_to do |format|
          format.html { redirect_to admin_store_path(@store), notice: "Store was successfully updated." }
          format.turbo_stream
        end
      else
        render :edit
      end
    end

    private

    def store_params
      params.require(:store).permit(:name, :meta_title, :meta_description, :about, :facebook_url, :instagram_url, :stripe_webhook_secret_key, :stripe_secret_key, :stripe_publishable_key)
    end
  end
end
