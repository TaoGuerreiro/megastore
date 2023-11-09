class ShippingMethod < ApplicationRecord
  belongs_to :store

  monetize :price_cents  # pour money-rails
end
