# frozen_string_literal: true

class Collection < ApplicationRecord
  has_many :items, dependent: :nullify
  belongs_to :store
  belongs_to :cover, class_name: "Item", optional: true

  validates :name, presence: true

  def has_cover?
    cover.present?
  end

  def cover_image
    cover&.photos&.first || items.first&.photos&.first
  end

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

  def photos_attached?
    return false unless items.first

    items.first.photos.attached?
  end
end
