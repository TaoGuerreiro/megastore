# id: 13,
# order_id: 19,
# amount_cents: 326,
# amount_currency: "EUR",

FactoryBot.define do
  factory :fee do
    order
    amount_cents { 333 }
    amount_currency { "EUR" }
  end
end
