FactoryGirl.define do
  factory :note do
    association :word
    association :user
    value { Faker::Hipster.word }
    rating { [*0..6].sample }
    vocabulary false
  end
end
