FactoryBot.define do
  factory :booking_step do
    association :booking
    step_type { "premier_contact" }
    comment { "Commentaire de test" }
  end
end
