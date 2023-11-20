class ShippingMethod < ApplicationRecord
  extend Enumerize

  belongs_to :store
  has_many :item_shipments, dependent: :destroy
  has_many :items, through: :item_shipments

  monetize :price_cents

  SERVICES = [:ups, :poste, :mr, :other].freeze
  enumerize :service_name, in: SERVICES, default: :poste, predicates: true
end
