class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :shipping_methods
  has_many :items
  has_many :specifications
  has_rich_text :about

  encrypts :stripe_publishable_key
  encrypts :stripe_secret_key
  encrypts :stripe_webhook_secret_key

  def availible_methods(ids)
    max_prices = ShippingMethod.joins(item_shipments: :item)
      .where(items: { id: ids })
      .select('shipping_methods.service_name, MAX(shipping_methods.price_cents) as max_price')
      .group('shipping_methods.service_name')
      .to_sql

    most_expensive_shipping_methods = ShippingMethod
      .joins("INNER JOIN (#{max_prices}) as max_prices ON shipping_methods.service_name = max_prices.service_name AND shipping_methods.price_cents = max_prices.max_price")

    most_expensive_shipping_methods
  end
end
