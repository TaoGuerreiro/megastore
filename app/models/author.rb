class Author < ApplicationRecord
  include Filterable

  belongs_to :store
  has_one_attached :avatar
  has_many :item_authors, dependent: :destroy
  has_many :items, through: :item_authors

  filterable do
    columns :nickname
    columns :bio
    columns :website
  end
end
