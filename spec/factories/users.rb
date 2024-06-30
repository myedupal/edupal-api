FactoryBot.define do
  factory :user do
    transient do
      selected_curriculum { create(:curriculum) }
    end
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    selected_curriculum_id { selected_curriculum&.id }

    trait :sign_in_with_google do
      oauth2_provider { 'google' }
      oauth2_sub { SecureRandom.uuid }
      oauth2_profile_picture_url { Faker::Internet.url }
    end
  end
end
