class Store < ApplicationRecord
  belongs_to :admin, class_name: 'User'
  has_many :categories
  has_many :shipping_methods
  has_many :items
  has_rich_text :about

  def availible_methods(weight)
    shipping_methods.where('max_weight >?', weight.to_i)
  end
end
