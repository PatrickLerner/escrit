require 'faker'

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    pwd = Faker::Internet.password
    password pwd
    password_confirmation pwd

    factory :admin do
      admin true
    end

    factory :current_user do
      after(:build) do |user|
        user.extend(User::Real)
        user.real = true
      end
    end

    factory :current_admin do
      admin true
      
      after(:build) do |user|
        user.extend(User::Real)
        user.real = true
      end
    end
  end
end
