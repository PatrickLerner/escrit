FactoryGirl.define do
  factory :user do
    sequence :name do |n|
      "#{Faker::Name.name} the #{n}"
    end
    sequence :email do |n|
      Faker::Internet.email(n)
    end
    p = Faker::Internet.password
    password p
    password_confirmation p
  end
end
