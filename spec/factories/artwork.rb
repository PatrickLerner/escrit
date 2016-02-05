FactoryGirl.define do
  factory :artwork do
    image { File.open(Rails.root.join('app', 'assets', 'images', 'factory.jpg')) }
    association :language
  end
end
