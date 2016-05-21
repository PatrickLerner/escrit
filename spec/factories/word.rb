FactoryGirl.define do
  factory :word do
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    language
    user
  end
end
