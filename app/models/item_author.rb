class ItemAuthor < ApplicationRecord
  belongs_to :item
  belongs_to :author
end
