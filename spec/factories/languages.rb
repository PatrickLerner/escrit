FactoryGirl.define do
  factory :language do
    sequence :name do |n|
      "Language #{n}"
    end
  end
end
