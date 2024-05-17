FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :sign_in_with_google do
      oauth2_provider { 'google' }
      oauth2_sub { SecureRandom.uuid }
      oauth2_profile_picture_url { Faker::Internet.url }
    end
  end
end
