FactoryBot.define do
  factory :store do
    sequence(:name) { |n| "Store #{n}" }
    street { "5000 Forbes Ave" }
    city   { "Pittsburgh" }
    state  { "PA" }
    zip    { "15213" }
    phone  { "4122683259" }
    active { true }
  end
end
