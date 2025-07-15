# frozen_string_literal: true

FactoryBot.define do
  factory :social_target do
    association :social_campagne
    name { "test_target" }
    kind { "hashtag" }
    cursor { nil }
    total_likes { 0 }
    posts_liked { [] }
    last_activity { nil }
  end

  factory :hashtag_target, parent: :social_target do
    kind { "hashtag" }
    name { "fashion" }
  end

  factory :account_target, parent: :social_target do
    kind { "account" }
    name { "influenceur_test" }
  end

  factory :social_target_with_stats, parent: :social_target do
    total_likes { 3 }
    posts_liked { ["post_123", "post_456", "post_789"] }
    last_activity { 1.hour.ago }
  end
end
