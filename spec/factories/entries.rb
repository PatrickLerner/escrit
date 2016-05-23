FactoryGirl.define do
  factory :entry do
    word
    token
    rating %w(0 1 2 3 4 5).sample
  end
end
