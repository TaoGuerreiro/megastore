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

  def holiday?
    holiday
  end

  def full_address
    "#{address}, #{postal_code} #{city}, #{country}"
  end
end
