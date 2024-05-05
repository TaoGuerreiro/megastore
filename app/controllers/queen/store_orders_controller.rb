# frozen_string_literal: true

module Queen
  class StoreOrdersController < QueenController
    def index
      @store_orders = StoreOrder.all
    end

    def show
    end
  end
end
