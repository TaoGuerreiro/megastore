# app/models/item.rb
class Order < ApplicationRecord
  extend Enumerize

  belongs_to :user
  belongs_to :payment_method
  has_many :order_items
  has_many :items, through: :order_items

  monetize :amount_cents

  STATUS = ['pending', 'paid', 'cancelled', 'refunded'].freeze

  enumerize :status, in: STATUS, default: 'pending', predicates: true

  def total_price
    if payment_method.present?
      amount + payment_method.price
    else
      amount
    end
  end
end
