# app/models/item.rb
class Item < ApplicationRecord
  belongs_to :store
  has_many_attached :photos

  monetize :price_cents  # pour money-rails
end
