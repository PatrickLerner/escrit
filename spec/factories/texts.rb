require 'faker'

FactoryGirl.define do
  factory :text do
    title { Faker::Lorem.sentence }
    category { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(3).join "\n\n" }
    association :user
    association :language
  end
end
