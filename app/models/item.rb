# app/models/item.rb
class Item < ApplicationRecord
  belongs_to :store
  belongs_to :category
  has_many_attached :photos
  has_many :order_items
  has_many :orders, through: :order_items

  monetize :price_cents  # pour money-rails
end
