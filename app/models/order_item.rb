# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :item
  belongs_to :order

  after_create :withdraw_stock

  def withdraw_stock
    item.update(stock: item.stock - quantity)
  end
end
