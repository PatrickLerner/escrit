require 'faker'

FactoryGirl.define do
  factory :word do
    value { Faker::Hipster.word.downcase }
    association :language
  end
end
