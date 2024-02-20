# frozen_string_literal: true

# app/models/item.rb
class Order < ApplicationRecord
  extend Enumerize
  include Presentable

  belongs_to :user
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  has_one_attached :label

  monetize :amount_cents
  monetize :shipping_cost_cents

  STATUSES = %w[pending confirmed paid canceled refunded sent].freeze

  enumerize :status, in: STATUSES, default: 'pending', predicates: true

  validates :amount, presence: true
  validates :status, presence: true
  validates :shipping_address, presence: true
  validates :user, presence: true

  def total_price
    if api_shipping_id.present?
      amount + shipping_cost
    else
      amount
    end
  end

  def total_price_cents
    if api_shipping_id.present?
      amount_cents + shipping_cost_cents
    else
      amount_cents
    end
  end
end
