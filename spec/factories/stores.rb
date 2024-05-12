# spec/factories/stores.rb
FactoryBot.define do
  factory :store do
    transient do
      endi_profile { false }
    end

    after(:build) do |instance, evaluator|
      unless evaluator.endi_profile
        instance.class.set_callback(:create, :after, :create_endi_profile)
        instance.class.skip_callback(:create, :after, :create_endi_profile)
      end
    end

    after(:create) do |instance, evaluator|
      unless evaluator.endi_profile
        instance.class.set_callback(:create, :after, :create_endi_profile)
      end
    end

    name { "My Store" }
    domain { "0.0.0.0:3030" }
    slug { "lecheveublanc" }
    association :admin, factory: :user
    created_at { Time.now }
    updated_at { Time.now }
    meta_title { "My Store Meta Title" }
    meta_description { "My Store Meta Description" }
    meta_image { "http:://example.com/logo.png" }
    instagram_url { "https://instagram.com/mystore" }
    facebook_url { "https://facebook.com/mystore" }
    about { "Je suis Clémence, illustratrice indépendante officiant à Nantes sous le pseudonyme Le Cheveu Blanc." }
    holiday { false }
    holiday_sentence { "Boutique en vacances" }
    display_stock { false }
    postmark_key { "postmark-key" }
    mail_body { "mail body text" }
    sendcloud_private_key { YAML.load_file('db/keys.yml')['sendcloud_private_key'] }
    sendcloud_public_key { YAML.load_file('db/keys.yml')['sendcloud_public_key'] }
    postal_code { "12345" }
    city { "My City" }
    country { "My Country" }
    address { "123 My Street" }
    rates { 0.2 }
    charges_enable { false }
    payouts_enable { false }
    details_submitted { false }
    stripe_account_id { "acct_1OuibPGd8WG5acSE" }
    stripe_subscription_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    stripe_checkout_session_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    subscription_status { "pending" }
    endi_auth { "auth_token" }
    endi_id { 1 }

    trait :with_items do
      transient do
        items_count { 3 }
      end
      after(:create) do |store, evaluator|
        create_list(:item, evaluator.items_count, store:)
      end
    end
  end

  factory :chalky, parent: :store do
    name { "My Second Store" }
    domain { "chalky.com" }
    slug { "chalky" }
    association :admin, factory: :queen
  end

  factory :random_store, parent: :store do
    name { Faker::Company.bs }
    domain { Faker::Internet.domain_name }
    slug { Faker::Alphanumeric.alphanumeric(number: 10) }
    association :admin, factory: :user
  end
end
