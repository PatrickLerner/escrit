FactoryGirl.define do
  factory :compliment do
    value { Faker::Lorem.sentence }
    association :language
  end
end
