module Admin
  class StoresController < ApplicationController
    before_action :authenticate_user!

    layout "admin"

    def my_store
      # raise
    end
  end
end
