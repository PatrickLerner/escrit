FactoryGirl.define do
  factory :language do
    sequence :name do |n|
      "#{Faker::Name.last_name} #{n}"
    end
    sequence :code do |n|
      ('aa'..'zz').to_a[n].downcase
    end
  end
end
