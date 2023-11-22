class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :shipping_methods
  has_many :items
  has_rich_text :about

  encrypts :stripe_publishable_key
  encrypts :stripe_secret_key
  encrypts :stripe_webhook_secret_key

  def availible_methods(weight)
    shipping_methods.where('max_weight >?', weight.to_i)
  end
end
