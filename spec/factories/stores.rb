# spec/factories/stores.rb
FactoryBot.define do
  factory :store do
    name { "My Store" }
    domain { "example.com" }
    slug { "lecheveublanc" }
    association :admin, factory: :user # Assurez-vous que vous avez une factory :user définie
    created_at { Time.now }
    updated_at { Time.now }
    meta_title { "My Store Meta Title" }
    meta_description { "My Store Meta Description" }
    meta_image { "http:://example.com/logo.png" }
    instagram_url { "https://instagram.com/mystore" }
    facebook_url { "https://facebook.com/mystore" }
    about_text { "Je suis Clémence, illustratrice indépendante officiant à Nantes sous le pseudonyme Le Cheveu Blanc." }
    holiday { false }
    holiday_sentence { "Boutique en vacances" }
    display_stock { false }
    postmark_key { "postmark-key" }
    mail_body { "mail body text" }
    sendcloud_private_key { "sendcloud-private-key" }
    sendcloud_public_key { "sendcloud-public-key" }
    postal_code { "12345" }
    city { "My City" }
    country { "My Country" }
    address { "123 My Street" }
    rates { 0.2 }
    stripe_account_id { "acct_1Example" }
    charges_enable { false }
    payouts_enable { false }
    details_submitted { false }
    stripe_subscription_id { "sub_1Example" }
    subscription_status { "pending" }
    stripe_checkout_session_id { "cs_test_example" }
    endi_auth { "auth_token" }
    endi_id { 1 }

    trait :with_items do
      transient do
        items_count { 3 }
      end
      after(:create) do |store, evaluator|
        create_list(:item, evaluator.items_count, store: store)
      end
    end
  end
end
