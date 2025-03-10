# frozen_string_literal: true

class Event < ApplicationRecord
  include Enumerize
  include PgSearch::Model

  enumerize :status, in: %i[pending processed failed], default: :pending

  pg_search_scope :search_by_source_and_data,
                  against: [:source, :data, :processing_errors],
                  using: {
                    tsearch: { prefix: true }
                  }
end
