# app/models/item.rb
class Order < ApplicationRecord
  extend Enumerize

  belongs_to :user
  belongs_to :shipping_method
  has_many :order_items
  has_many :items, through: :order_items

  monetize :amount_cents

  STATUS = ["pending", "confirmed", "paid", "cancelled", "refunded"].freeze

  enumerize :status, in: STATUS, default: "pending", predicates: true

  def total_price
    if shipping_method.present?
      amount + shipping_method.price
    else
      amount
    end
  end

  def total_price_cents
    if shipping_method.present?
      amount_cents + shipping_method.price_cents
    else
      amount_cents
    end
  end
end
