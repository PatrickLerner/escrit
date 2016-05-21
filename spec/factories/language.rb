FactoryGirl.define do
  factory :language do
    name Faker::Name.last_name
    sequence :code do |n|
      ('aa'..'zz').to_a[n].downcase
    end
  end
end
