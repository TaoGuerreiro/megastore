module Admin
  class StoresController < ApplicationController
    before_action :authenticate_user!

    layout "admin"

    def my_store
      # raise
    end

    def show
      @store = Current.store
      @categories = Current.store.categories
    end

    def edit
      @store = Current.store
    end

    def update
      @store = Store.find(params[:id])
      if @store.update(store_params)
        redirect_to admin_store_path, notice: "Store updated successfully"
      else
        render :edit
      end
    end

    private

    def store_params
      params.require(:store).permit(:name, :meta_title, :meta_description, :about_text, :facebook_url, :instagram_url)
    end
  end
end
