
FactoryBot.define do
  factory :item do
    name { "My Item" }
    description { "My Item Description" }
    price { 100 }
    image { "path/to/image.jpg" }
  end
end
