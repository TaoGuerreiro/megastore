
require "open-uri"

OrderItem.destroy_all
Order.destroy_all
PaymentMethod.destroy_all
Item.destroy_all
Category.destroy_all
Store.destroy_all
User.destroy_all

admin_localhost = User.create(first_name: "Ted", last_name: "Lasso", email: "admin@example.fr", password: "123456", role: "admin")
clemence = User.create(first_name: "Clémence", last_name: "Porcheret", email: "hello@lecheveublanc.fr", password: "123456", role: "admin")

unless Rails.env == "development"
  store = clemence.stores.create({
    domain: "lecheveublanc.fr",
    name: "Le Cheveu Blanc",
    slug: "lecheveublanc",
    meta_title: "Le Cheveu Blanc",
    meta_description: "Illustrations militantes from Nantes",
    meta_image: "lecheveublanc/clemence.jpg",
    instagram_url: "https://www.instagram.com/le_cheveu_blanc/",
    facebook_url: "https://www.facebook.com/lecheveublanc/"
  })
else
  store = clemence.stores.create({
    domain: "localhost",
    name: "Le Cheveu Blanc",
    slug: "lecheveublanc",
    meta_title: "Le Cheveu Blanc",
    meta_description: "Illustrations militantes from Nantes",
    meta_image: "lecheveublanc/clemence.jpg",
    instagram_url: "https://www.instagram.com/le_cheveu_blanc/",
    facebook_url: "https://www.facebook.com/lecheveublanc/"
  })
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
      file_2 = URI.open("https://loremflickr.com/320/240")
      file_3 = URI.open("https://picsum.photos/200/300")
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
      item.photos.attach([
        { io: file, filename: "nes.png", content_type: "image/png" },
        { io: file_2, filename: "nes_2.png", content_type: "image/png" },
        { io: file_3, filename: "nes_3.png", content_type: "image/png" }
      ])
      item.save
    end

    PaymentMethod.create(store: store, name: "UPS", description: "Dans les 48h", price: 8)
    PaymentMethod.create(store: store, name: "Mondial relay", description: "entre 2 à 5 jours", price: 4)
    PaymentMethod.create(store: store, name: "Remise en main propre", description: "Très propre", price: 0)
end
