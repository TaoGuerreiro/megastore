# app/models/category.rb
class Category < ApplicationRecord
  belongs_to :store
  # ... autres codes ...
end
