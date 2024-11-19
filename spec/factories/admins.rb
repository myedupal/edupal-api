FactoryBot.define do
  factory :admin do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    super_admin { true }

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
