class ItemShipment < ApplicationRecord
  belongs_to :item
  belongs_to :shipping_method
end
