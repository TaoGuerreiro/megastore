# frozen_string_literal: true

class Specification < ApplicationRecord
  has_many :item_specifications
  has_many :items, through: :item_specifications
  belongs_to :store

  validates :name, presence: true
end
