# app/models/item.rb
class Order < ApplicationRecord
  extend Enumerize
  include Presentable

  belongs_to :user
  belongs_to :shipping_method
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items

  monetize :amount_cents

  STATUSES = ["pending", "confirmed", "paid", "canceled", "refunded", "sent"].freeze

  enumerize :status, in: STATUSES, default: "pending", predicates: true

  validates :amount, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :shipping_method, presence: true

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

  def store
    items.first.store
  end

  def shipping_method
    nil
  end
end
