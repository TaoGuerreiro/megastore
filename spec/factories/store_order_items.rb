# id: 16,
# orderable_type: "Shipping",
# orderable_id: 12,
# price_cents: 155,
# price_currency: "EUR",
# created_at: Sun, 26 May 2024 17:29:34.098334000 CEST +02:00,
# updated_at: Sun, 26 May 2024 17:29:34.098334000 CEST +02:00,
# store_order_id: 3,
# endi_line_id: nil>

FactoryBot.define do
  factory :store_order_item do
    store_order
    price_cents { 155 }
    price_currency { "EUR" }

    association :orderable, factory: :shipping
  end
end
