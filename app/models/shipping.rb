# frozen_string_literal: true

class Shipping < ApplicationRecord
  belongs_to :order
  has_many :store_order_items, as: :orderable, dependent: :destroy
  has_one :store_order, through: :store_order_items
  monetize :cost_cents

  validates :api_shipping_id, presence: true
  validates :method_carrier, presence: true
  validates :cost_cents, presence: true
  validates :address_first_line, presence: true
  validates :city, presence: true
  validates :country, presence: true

  def full_address
    "#{address_first_line} #{address_second_line}, #{postal_code} #{city}, #{country}"
  end

  def street
    "#{address_first_line} #{address_second_line}"
  end
end
