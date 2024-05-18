# frozen_string_literal: true

class OrderItem < ApplicationRecord
  belongs_to :item, class_name: "Item", foreign_key: "item_id"
  belongs_to :order, class_name: "Order", foreign_key: "order_id"

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
