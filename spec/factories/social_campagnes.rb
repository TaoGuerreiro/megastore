# frozen_string_literal: true

FactoryBot.define do
  factory :social_campagne do
    association :user
    status { "active" }
    name { "Campagne principale" }
  end

  factory :paused_social_campagne, parent: :social_campagne do
    status { "paused" }
    name { "Campagne en pause" }
  end
end
