FactoryBot.define do
  factory :category do
    name { "My Category" }
    store { create(:store) }
  end
end
