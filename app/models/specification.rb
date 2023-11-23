class Specification < ApplicationRecord
  has_many :item_specifications
  has_many :items, through: :item_specifications
  belongs_to :store
end
