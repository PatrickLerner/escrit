FactoryGirl.define do
  factory :compliment do
    sequence :value do |n|
      "You are number #{n}!"
    end
    language
  end
end
