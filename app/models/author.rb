class Author < ApplicationRecord
  include Filterable

  belongs_to :store
  has_many :item_authors, dependent: :destroy
  has_many :items, through: :item_authors
  has_one_attached :avatar

  filterable do
    columns :nickname
    columns :bio
    columns :website
  end
end
