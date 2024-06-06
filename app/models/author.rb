class Author < ApplicationRecord
  belongs_to :store
  has_one_attached :avatar
  has_many :item_authors, dependent: :destroy
  has_many :items, through: :item_authors
end
