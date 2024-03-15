# frozen_string_literal: true

require 'open-uri'

return unless Rails.env.development?

OrderItem.destroy_all
Order.destroy_all
ItemSpecification.destroy_all
Specification.destroy_all
Item.destroy_all
Category.destroy_all
Store.destroy_all
User.destroy_all

admin_localhost = User.create(first_name: 'Ted', last_name: 'Lasso', email: 'admin@example.fr', password: '123456',
                              role: 'admin', phone: '0674236080')
clemence = User.create(first_name: 'Clémence', last_name: 'Porcheret', email: 'hello@lecheveublanc.fr',
                       password: '123456', role: 'admin', phone: '0674236080')
unsafe = User.create(first_name: 'Tao', last_name: 'Guerreiro', email: 'hello@unsafehxc.fr', password: '123456',
                     role: 'admin', phone: '0674236080')
salome = User.create(first_name: 'Salomé', last_name: 'Dubart', email: 'hello@studioanemone.fr', password: '123456',
                     role: 'admin', phone: '0674236080')
flo = User.create(first_name: 'Flo', last_name: 'Queen', email: 'florent.guilbaud@gmail.com', password: '123456',
                  role: 'queen', phone: '0674236080')

store_one = clemence.stores.create({
                                     domain: 'localhost',
                                     name: 'Le Cheveu Blanc',
                                     slug: 'lecheveublanc',
                                     meta_title: 'Le Cheveu Blanc',
                                     meta_description: 'Illustrations militantes from Nantes',
                                     meta_image: 'lecheveublanc/meta_image.jpg',
                                     instagram_url: 'https://www.instagram.com/le_cheveu_blanc/',
                                     facebook_url: 'https://www.facebook.com/lecheveublanc/',
                                     mail_body: 'Merci pour ta commande frero',
                                     address: '1 rue de la paix',
                                     city: 'Nantes',
                                     postal_code: '44000',
                                     country: 'France',
                                     stripe_publishable_key: YAML.load_file('db/keys.yml')['stripe_publishable_key'],
                                     stripe_secret_key: YAML.load_file('db/keys.yml')['stripe_secret_key'],
                                     stripe_webhook_secret_key: YAML.load_file('db/keys.yml')['stripe_webhook_secret_key'],
                                     postmark_key: YAML.load_file('db/keys.yml')['postmark_key'],
                                     sendcloud_private_key: YAML.load_file('db/keys.yml')['sendcloud_private_key'],
                                     sendcloud_public_key: YAML.load_file('db/keys.yml')['sendcloud_public_key']
                                   })

store_two = unsafe.stores.create({
                                   domain: 'ngrok.io',
                                   name: 'Unsafe',
                                   slug: 'unsafe',
                                   meta_title: 'Unsafe',
                                   meta_description: 'Metal Hardcore from Nantes',
                                   meta_image: 'unsafe/meta_image.jpg',
                                   instagram_url: 'https://www.instagram.com/unsafehc/',
                                   facebook_url: 'https://www.facebook.com/unsafehc/',
                                   mail_body: 'Merci pour ta commande frero',
                                   address: '1 rue de la paix',
                                   city: 'Nantes',
                                   postal_code: '44000',
                                   country: 'France',
                                   stripe_publishable_key: YAML.load_file('db/keys.yml')['stripe_publishable_key'],
                                   stripe_secret_key: YAML.load_file('db/keys.yml')['stripe_secret_key'],
                                   stripe_webhook_secret_key: YAML.load_file('db/keys.yml')['stripe_webhook_secret_key'],
                                   postmark_key: YAML.load_file('db/keys.yml')['postmark_key'],
                                   sendcloud_private_key: YAML.load_file('db/keys.yml')['sendcloud_private_key'],
                                   sendcloud_public_key: YAML.load_file('db/keys.yml')['sendcloud_public_key']
                                 })

store_three = salome.stores.create({
                                     domain: 'old_localhost',
                                     name: 'Studio Anémone',
                                     slug: 'anemone',
                                     meta_title: 'Studio Anémone',
                                     meta_description: 'Céramique from Vannes',
                                     meta_image: 'anemone/meta_image.jpg',
                                     instagram_url: 'https://www.instagram.com/studio.anemone/',
                                     facebook_url: 'https://www.facebook.com/',
                                     mail_body: 'Merci pour ta commande frero',
                                     address: '1 rue de la paix',
                                     city: 'Nantes',
                                     postal_code: '44000',
                                     country: 'France',
                                     stripe_publishable_key: YAML.load_file('db/keys.yml')['stripe_publishable_key'],
                                     stripe_secret_key: YAML.load_file('db/keys.yml')['stripe_secret_key'],
                                     stripe_webhook_secret_key: YAML.load_file('db/keys.yml')['stripe_webhook_secret_key'],
                                     postmark_key: YAML.load_file('db/keys.yml')['postmark_key'],
                                     sendcloud_private_key: YAML.load_file('db/keys.yml')['sendcloud_private_key'],
                                     sendcloud_public_key: YAML.load_file('db/keys.yml')['sendcloud_public_key']
                                   })

[store_one, store_two, store_three].each do |store|
  categories = []
  %i[stickers print illustration].each do |category|
    category = Category.create({
                                 store:,
                                 name: category
                               })

    categories << category
  end

  10.times do
    file = URI.open('https://source.unsplash.com/random/300x300/?illustration')
    file_2 = URI.open('https://source.unsplash.com/random/300x300/?cat')
    file_3 = URI.open('https://source.unsplash.com/random/300x300/?dog')
    item = Item.new({
                      name: Faker::Commerce.product_name,
                      description: "#{Faker::Commerce.material} #{Faker::Commerce.product_name}",
                      price_cents: Faker::Number.number(digits: 5),
                      price_currency: 'EUR',
                      store:,
                      active: true,
                      category: categories.sample,
                      stock: Faker::Number.between(from: 0, to: 100),
                      weight: Faker::Number.between(from: 20, to: 1000),
                      length: Faker::Number.between(from: 1, to: 100),
                      width: Faker::Number.between(from: 1, to: 100),
                      height: Faker::Number.between(from: 1, to: 100)
                    })
    item.photos.attach([
                         { io: file, filename: 'nes.png', content_type: 'image/png' },
                         { io: file_2, filename: 'nes_2.png', content_type: 'image/png' },
                         { io: file_3, filename: 'nes_3.png', content_type: 'image/png' }
                       ])
    item.save
  end
end
