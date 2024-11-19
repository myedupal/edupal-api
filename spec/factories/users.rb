FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }

    trait :with_curriculum do
      transient do
        selected_curriculum { create(:curriculum) }
      end

      selected_curriculum_id { selected_curriculum&.id }
    end

    trait :sign_in_with_google do
      oauth2_provider { 'google' }
      oauth2_sub { SecureRandom.uuid }
      oauth2_profile_picture_url { Faker::Internet.url }
    end

    trait :with_organization do
      transient do
        selected_organization { create(:organization) }
      end

      after(:create) do |user, evaluator|
        create(:organization_account, organization: evaluator.selected_organization, account: user, role: :trainee)
        user.update(selected_organization: evaluator.selected_organization)
      end
    end
  end
end
