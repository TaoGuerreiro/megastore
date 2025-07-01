class BookingContact < ApplicationRecord
  has_many :bookings, dependent: :destroy

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :language, inclusion: { in: %w[fr en es] }, allow_blank: true

  def full_address
    [address, city, state, zip_code, country].compact.join(", ")
  end

  def locale
    language.presence || "fr"
  end
end
