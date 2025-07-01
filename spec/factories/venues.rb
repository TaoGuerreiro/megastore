FactoryBot.define do
  factory :venue do
    sequence(:name) { |n| "Salle #{n}" }
    address { "123 Rue de la Musique" }
    city { "Paris" }
    state { "Île-de-France" }
    zip_code { "75001" }
    country { "France" }
    phone { "+33 1 23 45 67 89" }
    email { "contact@salle-musique.fr" }
    capacity { rand(50..500) }
    language { %w[fr en es].sample }
  end
end
