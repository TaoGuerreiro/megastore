FactoryBot.define do
  factory :booking_contact do
    sequence(:name) { |n| "Contact #{n}" }
    sequence(:email) { |n| "contact#{n}@example.com" }
    phone { "+33 6 #{rand(10..99)} #{rand(10..99)} #{rand(10..99)} #{rand(10..99)}" }
    address { "#{rand(1..100)} Rue des Contacts" }
    city { ["Paris", "Lyon", "Marseille", "Bordeaux", "Toulouse"].sample }
    state { ["Île-de-France", "Rhône-Alpes", "Provence-Alpes-Côte d'Azur", "Nouvelle-Aquitaine", "Occitanie"].sample }
    zip_code { rand(10000..99999).to_s }
    country { "France" }
    notes { "Notes importantes sur ce contact" }
    language { %w[fr en es].sample }
  end
end
