# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :item
  belongs_to :order

  after_create :withdraw_stock
  after_destroy :add_stock

  def withdraw_stock
    item.update(stock: item.stock - quantity)

    item.update(status: :offline) if item.soldout?
  end

  def add_stock
    item.update(stock: item.stock + quantity)

    item.update(status: :active) if item.stock.positive?
  end
end
