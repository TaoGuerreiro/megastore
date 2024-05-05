FactoryBot.define do
  factory :user do
    first_name { "Florent" }
    last_name { "Guilbaud" }
    email { "H8zP7@example.com" }
    phone { "0674236080" }
    password { "password" }
    password_confirmation { "password" }
    role { "admin" }
  end
end
