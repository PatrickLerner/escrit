require 'faker'

FactoryGirl.define do
  factory :service do
    sequence :name do |n|
      "service #{n}"
    end
    sequence :short_name do |n|
      "srv #{n}"
    end
    url { "#{Faker::Internet.url}?q={query}" }
    association :language
    association :user
  end
end
