require 'faker'

FactoryGirl.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    pwd = Faker::Internet.password
    password pwd
    password_confirmation pwd
    role User.roles[:citizen]

    factory :admin do
      role User.roles[:doge]
    end
  end
end
