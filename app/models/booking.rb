# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :gig, optional: true
  belongs_to :booking_contact, optional: true
  belongs_to :venue, optional: true
  has_many :booking_steps, dependent: :destroy

  accepts_nested_attributes_for :gig

  validates :notes, length: { maximum: 1000 }, allow_blank: true

  def last_step
    booking_steps.order(created_at: :desc).first
  end

  def status
    if last_step.nil?
      "pending"
    else
      last_step.step_type
    end
  end
end
