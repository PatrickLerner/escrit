FactoryGirl.define do
  factory :occurrence do
    association :word
    association :text
  end
end
