
require "open-uri"
Category.destroy_all
Item.destroy_all
Store.destroy_all
User.destroy_all

admin_localhost = User.create(first_name: "Ted", last_name: "Lasso", email: "admin@example.fr", password: "123456", role: "admin")
clemence = User.create(first_name: "Clémence", last_name: "Porcheret", email: "hello@lecheveublanc.fr", password: "123456", role: "admin")

if Rails.env == "development"
  store = clemence.stores.create({
    domain: "localhost",
    name: "Le Cheveu Blanc",
    slug: "lecheveublanc",
    meta_title: "Le Cheveu Blanc Illustration",
    meta_description: "Illustrations militantes from Nantes",
    meta_image: "lecheveublanc/clemence.jpg",
    instagram_url: "https://www.instagram.com/le_cheveu_blanc/",
    facebook_url: "https://www.facebook.com/lecheveublanc/"
  })
else
  clemence.stores.create({
    domain: "lecheveublanc.fr",
    name: "Le Cheveu Blanc",
    slug: "lecheveublanc",
    meta_title: "Le Cheveu Blanc Illustration",
    meta_description: "Illustrations militantes from Nantes",
    meta_image: "lecheveublanc/clemence.jpg",
    instagram_url: "https://www.instagram.com/le_cheveu_blanc/",
    facebook_url: "https://www.facebook.com/lecheveublanc/"
  })
end
categories = []
[:stickers, :print, :illustration].each do |category|
  category = Category.create({
    store: store,
    name: category
  })

  categories << category
end

10.times do
  file = URI.open("https://source.unsplash.com/random/300x300/?illustration")
  item = Item.new({
    name: Faker::Commerce.product_name,
    description:  Faker::Commerce.material + " " + Faker::Commerce.product_name,
    price_cents: Faker::Number.number(digits: 5),
    price_currency: "EUR",
    store: store,
    category: categories.sample,
    stock: Faker::Number.between(from: 0, to: 100),
    weight: Faker::Number.decimal(l_digits: 2, r_digits: 2),
    length: Faker::Number.between(from: 1, to: 100),
    width: Faker::Number.between(from: 1, to: 100),
    height: Faker::Number.between(from: 1, to: 100)
  })
  item.photos.attach(io: file, filename: "nes.png", content_type: "image/png")
  item.save
end
