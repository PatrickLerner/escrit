FactoryGirl.define do
  factory :note do
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    word
  end
end
