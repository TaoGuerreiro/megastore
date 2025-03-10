# frozen_string_literal: true

class Event < ApplicationRecord
  include Enumerize

  enumerize :status, in: %i[pending processed failed], default: :pending
end
