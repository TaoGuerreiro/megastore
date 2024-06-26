# id: 19,
# amount_cents: 1200,
# amount_currency: "EUR",
# status: "paid",
# user_id: 19,
# created_at: Sun, 26 May 2024 18:24:24.537694000 CEST +02:00,
# updated_at: Sun, 26 May 2024 18:24:33.916330000 CEST +02:00,
# checkout_session_id: "cs_test_b1VRBXRJAYf6kLLSpDsyFU4kh75rWxKno5mgQwCuuBJzkdVG8wMq7YWrA5",
# store_id: 11,
# fees_cents: 0,
# fees_currency: "EUR">

FactoryBot.define do
  factory :order do
    amount_cents { 1000 }
    amount_currency { "EUR" }
    status { "pending" }
    user { create(:client) }
    store

    after(:build) do |order|
      order.shipping ||= FactoryBot.build(:shipping, order: order)
      order.fee ||= FactoryBot.build(:fee, order: order)
    end
  end
end
