class Collection < ApplicationRecord
  has_many :items
  has_one :store, through: :items

  def max_item_price
    return 0 unless items.any?

    items.maximum(:price_cents) / 100.00
  end

  def min_item_price
    return 0 unless items.any?

    items.minimum(:price_cents) / 100.00
  end

  def stock
    return 0 unless items.any?

    items.sum(:stock)
  end

  def active?
    return false unless items.any?

    items.any?(&:active?)
  end

  def cover_image
    return unless items.first

    items.first.photos.first
  end

  def photos_attached?
    return false unless items.first

    items.first.photos.attached?
  end
end
