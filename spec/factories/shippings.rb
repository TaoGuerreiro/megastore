# id: 13,
# order_id: 19,
# api_shipping_id: 1345,
# api_service_point_id: nil,
# api_tracking_number: "XW722218600JB",
# api_tracking_url:
#  "https://tracking.eu-central-1-0.sendcloud.sc/forward?carrier=chronopost&code=XW722218600JB&destination=FR&lang=fr-fr&source=FR&type=parcel&verification=44230&servicepoint_verification=&created_at=2024-05-26",
# api_method_name: "Chrono 18 0-2kg",
# parcel_id: 379576114,
# method_carrier: "chronopost",
# service_point_address: nil,
# service_point_name: nil,
# cost_cents: 1632,
# cost_currency: "EUR",
# address: nil,
# country: "FR",
# city: "saint sébastien sur loire",
# postal_code: "44230",
# weight: "6",
# full_name: "GUILBAUD Florent",
# created_at: Sun, 26 May 2024 18:24:24.556382000 CEST +02:00,
# updated_at: Sun, 26 May 2024 18:29:20.761288000 CEST +02:00,
# api_error: nil,
# street_number: nil,
# address_first_line: "26 bis rue",
# address_second_line: "aristide briand",
# status: "Cancellation requested"

FactoryBot.define do
  factory :shipping do
    order
    api_shipping_id { 1345 }
    api_tracking_number { "XW722218600JB" }
    api_method_name { "Chrono 18 0-2kg" }
    parcel_id { 379576114 }
    method_carrier { "chronopost" }
    service_point_address { nil }
    service_point_name { nil }
    cost_currency { "EUR" }
    cost_cents { 1632 }
    address_first_line { "26 bis rue" }
    address_second_line { "aristide briand" }
    country { "FR" }
    city { "saint sébastien sur loire" }
    postal_code { "44230" }
    weight { "6" }
    full_name { "GUILBAUD Florent" }
    status { "Cancellation requested" }
  end
end
