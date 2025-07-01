class Gig < ApplicationRecord
  # belongs_to :venue
  has_many :bookings, dependent: :destroy

  validates :date, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :upcoming, -> { where("date >= ?", Date.current).order(:date, :time) }
  scope :past, -> { where("date < ?", Date.current).order(date: :desc, time: :desc) }

  def datetime
    date.to_datetime + time.seconds_since_midnight.seconds
  end
end
