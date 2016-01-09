require 'faker'

FactoryGirl.define do
  factory :word do
    value { Faker::Hipster.word }
    association :language
  end
end
