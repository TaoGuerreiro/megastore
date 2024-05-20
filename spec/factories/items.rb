
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

    after(:build) do |item|
      item.photos.attach(io: File.open(Rails.root.join('app/assets/images/lecheveublanc/acab/1.webp')), filename: 'image.jpg')
    end
  end

  factory :inactive_item, parent: :item do
    status { "offline" }
  end

  factory :the_item, parent: :item do
    name { "The Item" }
    status { "offline" }
  end
end
