# frozen_string_literal: true

class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :items
  has_many :specifications
  has_many :orders
  has_rich_text :about

  encrypts :stripe_publishable_key
  encrypts :stripe_secret_key
  encrypts :stripe_webhook_secret_key
  encrypts :postmark_key
  encrypts :sendcloud_private_key
  encrypts :sendcloud_public_key

  validates :slug, uniqueness: true
  validates :holiday_sentence, presence: true, if: :holiday?
  validates :postal_code, :city, :country, :address, :name, :domain, :slug, presence: true


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
