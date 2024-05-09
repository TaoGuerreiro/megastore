FactoryBot.define do
  factory :user do
    first_name { "Admin" }
    last_name { "Guilbaud" }
    email { Faker::Internet.email }
    phone { "0674236080" }
    password { "password" }
    password_confirmation { "password" }
    role { "admin" }
  end

  factory :queen, parent: :user do
    first_name { "Florent" }
    last_name { "Guilbaud" }
    email { "chalky@example.com" }
    role { "queen" }
  end
end
