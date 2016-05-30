FactoryGirl.define do
  factory :word do
    sequence :value do |n|
      "abcd#{n}efg"
    end
    language
    user

    factory :word_with_tokens do
      transient do
        token_count 3
      end

      after(:create) do |word, evaluator|
        create_list(:entry, evaluator.token_count, word: word)
      end
    end
  end
end
