FactoryBot.define do
  factory :gig do
    date { Date.current + rand(1..30).days }
    time { Time.current.change(hour: rand(19..23), min: 0, sec: 0) }
    duration { "#{rand(1..3)} hours" }
    price { rand(10..100) }
    description { "Concert exceptionnel avec des artistes talentueux" }
  end
end
