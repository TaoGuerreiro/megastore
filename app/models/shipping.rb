# frozen_string_literal: true

class Shipping < ApplicationRecord
  belongs_to :order
  has_many :store_order_items, as: :orderable
  has_one :store_order, through: :store_order_items
  monetize :cost_cents

  def full_address
    "#{address_first_line} #{address_second_line}, #{postal_code} #{city}, #{country}"
  end
end
