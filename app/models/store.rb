class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :shipping_methods
  has_many :items
  has_many :specifications
  has_many :orders
  has_rich_text :about

  encrypts :stripe_publishable_key
  encrypts :stripe_secret_key
  encrypts :stripe_webhook_secret_key
  encrypts :postmark_key
  encrypts :sendcloud_private_key
  encrypts :sendcloud_public_key

  def holiday?
    holiday
  end

  def availible_methods(ids)
    max_prices = ShippingMethod.where(store: self)
      .joins(item_shipments: :item)
      .where(items: { id: ids })
      .select('shipping_methods.service_name, MAX(shipping_methods.price_cents) as max_price')
      .group('shipping_methods.service_name')
      .to_sql

    most_expensive_shipping_methods = ShippingMethod.where(store: self)
      .joins("INNER JOIN (#{max_prices}) as max_prices ON shipping_methods.service_name = max_prices.service_name AND shipping_methods.price_cents = max_prices.max_price")

    most_expensive_shipping_methods
  end

  def full_address
    "#{address}, #{postal_code} #{city}, #{country}"
  end
end
