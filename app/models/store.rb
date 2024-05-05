# frozen_string_literal: true

class Store < ApplicationRecord
  belongs_to :admin, class_name: "User"
  has_many :categories
  has_many :items
  has_many :specifications
  has_many :orders
  has_many :collections
  has_rich_text :about

  encrypts :postmark_key
  encrypts :sendcloud_private_key
  encrypts :sendcloud_public_key

  validates :slug, uniqueness: true
  validates :holiday_sentence, presence: true, if: :holiday?
  validates :postal_code, :city, :country, :address, :name, :domain, :slug, presence: true

  after_create :create_endi_profile

  def create_endi_profile
    EndiServices::NewUser.new(self).call
  end

  def collections_with_items
    collections.includes(:items).where(items: { status: :active }).order(created_at: :desc)
  end

  def holiday?
    holiday
  end

  def active_subscription?
    stripe_subscription_id.present? && subscription_status == "active"
  end

  def full_address
    "#{address}, #{postal_code} #{city}, #{country}"
  end

  def stripe_account_completed?
    stripe_account_id.present? && details_submitted && charges_enable && payouts_enable
  end
end
