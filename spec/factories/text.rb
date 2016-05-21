FactoryGirl.define do
  factory :text do
    category Faker::Hipster.sentence.gsub(/\.$/, '')
    title Faker::Hipster.sentence.gsub(/\.$/, '')
    content Faker::Hipster.paragraphs(1 + Random.rand(10)).join('\n\n')
    language
    user
  end
end
