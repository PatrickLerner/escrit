FactoryGirl.define do
  factory :token do
    sequence :value do |n|
      "#{Faker::Lorem.word}#{n}"
    end

    factory :token_with_words do
      transient do
        word_count 3
        user create(:user)
      end

      after(:create) do |token, evaluator|
        l = create(:language)
        words = create_list(:word, evaluator.word_count, user: evaluator.user,
                                                         language: l)
        words.each do |word|
          Entry.create(word: word, token: token, rating: 3)
        end
        Word.reindex
      end
    end
  end
end
