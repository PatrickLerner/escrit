FactoryGirl.define do
  factory :token do
    value Faker::Lorem.word

    factory :token_with_words do
      transient do
        word_count 3
        language create(:language)
      end

      after(:create) do |token, evaluator|
        u = create(:user)
        l = evaluator.language
        words = create_list(:word, evaluator.word_count, user: u, language: l)
        words.each do |word|
          word.tokens << token
        end
      end
    end
  end
end
