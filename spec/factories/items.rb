
FactoryBot.define do
  factory :item do
    name { "My Item" }
    description { "My Item Description" }
    price { 10.0 }
    stock { 10 }
    status { "active" }
    weight { 10.0 }
    height { 10.0 }
    width { 10.0 }
    length { 10.0 }
    format { "A4" }
    category { create(:category, store:) }
    store { create(:store) }
  end
end
