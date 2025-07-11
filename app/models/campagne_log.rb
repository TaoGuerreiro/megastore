# frozen_string_literal: true

class CampagneLog < ApplicationRecord
  belongs_to :social_campagne

  validates :event_type, presence: true
  validates :logged_at, presence: true
end
