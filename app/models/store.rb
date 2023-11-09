class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :payment_methods
  has_many :items
  has_rich_text :about
end
