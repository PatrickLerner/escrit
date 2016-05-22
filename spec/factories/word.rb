FactoryGirl.define do
  factory :word do
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end
    language
    user

    factory :word_with_tokens do
      transient do
        token_count 3
      end

      after(:create) do |word, evaluator|
        tokens = create_list(:token, evaluator.token_count)
        tokens.each do |token|
          word.tokens << token
        end
      end
    end
  end
end
