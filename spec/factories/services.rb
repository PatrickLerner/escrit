require 'faker'

FactoryGirl.define do
  factory :service do
    name { Faker::Internet.user_name }
    short_name { Faker::Internet.user_name }
    url { "#{Faker::Internet.url}?q={query}" }
    association :language
    association :user
  end
end
