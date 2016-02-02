require 'faker'

FactoryGirl.define do
  factory :service do
    name { Faker::Company.buzzword }
    short_name { Faker::Internet.user_name }
    url { Faker::Internet.url }
    association :language
    association :user
  end
end
