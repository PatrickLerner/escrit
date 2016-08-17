FactoryGirl.define do
  factory :category do
    name Faker::Hipster.sentence.gsub(/\.$/, '')
    user
    language
  end
end
