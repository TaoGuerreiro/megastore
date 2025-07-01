FactoryBot.define do
  factory :booking do
    association :gig
    association :booking_contact
    association :venue
    notes { "Réservation effectuée avec succès" }
  end
end
