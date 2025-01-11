FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }

    trait :admin do
      role { 'admin' }
    end

    trait :regular_user do
      role { 'user' }
    end
  end
end
