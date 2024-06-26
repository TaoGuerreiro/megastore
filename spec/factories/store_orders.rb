FactoryBot.define do
  factory :store_order do
    status { "pending" }
    amount_cents { 1234 }
    amount_currency { "EUR" }
    store { create(:store) || association(:store) }
    date { Date.current }
    endi_id { nil }
  end
end
