# frozen_string_literal: true

module Admin
  class StockPolicy < ApplicationPolicy
    def add_stock?
      queen_or_store_record?
    end

    def remove_stock?
      queen_or_store_record?
    end
  end
end
