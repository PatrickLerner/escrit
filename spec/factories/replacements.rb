FactoryGirl.define do
  factory :replacement do
    value { Faker::Hipster.word[0] }
    replacement { Faker::Hipster.word[0] }
    association :language
  end
end
