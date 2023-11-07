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
  end
end
