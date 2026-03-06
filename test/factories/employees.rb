FactoryBot.define do
  factory :employee do
    first_name     { "Alex" }
    last_name      { "Heimann" }
    ssn            { "123456789" }
    date_of_birth  { 20.years.ago.to_date }
    phone          { "4122688211" }
    role           { :manager }
    active         { true }
  end
end
