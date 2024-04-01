class Collection < ApplicationRecord
  has_many :items, dependent: :nullify
  belongs_to :store

  validates :name, presence: true


  def soldout?
    return false unless items.any?

    items.all? { |item| item.stock.zero? }
  end

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

  def status
    active? ? :active : :inactive
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
