FactoryGirl.define do
  factory :text do
    sequence :category do |n|
      "#{Faker::Hipster.sentence.gsub(/\.$/, '')} #{n}"
    end
    title Faker::Hipster.sentence.gsub(/\.$/, '')
    content Faker::Hipster.paragraphs(1 + Random.rand(10)).join('\n\n')
    language
    user
  end
end
