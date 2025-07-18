# frozen_string_literal: true

class Discount < ApplicationRecord
  belongs_to :order
  monetize :amount_cents
end
