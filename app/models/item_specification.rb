# frozen_string_literal: true

class ItemSpecification < ApplicationRecord
  belongs_to :item
  belongs_to :specification
end
