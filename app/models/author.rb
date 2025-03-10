class Author < ApplicationRecord
  include Filterable
  include PgSearch::Model

  belongs_to :store
  has_many :item_authors, dependent: :destroy
  has_many :items, through: :item_authors
  has_one_attached :avatar

  filterable do
    columns :nickname
    columns :bio
    columns :website
  end

  pg_search_scope :search_by_term,
                  against: {
                    nickname: "A",
                    bio: "B",
                    website: "C"
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  validates :nickname, presence: true
end
