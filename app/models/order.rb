# frozen_string_literal: true

# app/models/item.rb
class Order < ApplicationRecord
  extend Enumerize
  include Presentable
  include PgSearch::Model

  delegate :address, to: :shipping, prefix: true, allow_nil: true

  belongs_to :user
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items
  has_one_attached :label
  has_one :shipping, dependent: :destroy
  has_one :fee, dependent: :destroy

  monetize :amount_cents

  pg_search_scope :search_by_client,
                  associated_against: {
                    user: %i[first_name last_name email],
                    shipping: %i[address_first_line address_second_line postal_code city country]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  STATUSES = %w[pending confirmed paid canceled refunded sent].freeze

  enumerize :status, in: STATUSES, default: 'pending', predicates: true

  validates :amount, presence: true
  validates :status, presence: true
  validates :user, presence: true

  def total_price
    if shipping&.api_shipping_id.present?
      amount + shipping.cost + fee.amount
    else
      amount
    end
  end

  def total_price_cents
    if shipping&.api_shipping_id.present?
      amount_cents + shipping.cost_cents + fee.amount_cents
    else
      amount_cents
    end
  end

  def logistic_and_shipping_price
    shipping.cost + fee.amount
  end

  def full_address
    "#{shipping.address}, #{shipping.postal_code} #{shipping.city}, #{shipping.country}"
  end
end
