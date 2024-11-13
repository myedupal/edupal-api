FactoryBot.define do
  factory :organization do
    transient do
      owner { create(:admin) }
    end
    owner_id { owner&.id }
    title { Faker::Lorem.words(number: 3).join(' ') }
    description { Faker::Lorem.paragraph }
    status { :active }
    maximum_headcount { 15 }

    trait :with_admin do
      transient do
        admin { create(:admin) }
        role {:admin}
      end

      after(:create) do |organization, evaluator|
        create(:organization_account, organization: organization, account: evaluator.admin, role: evaluator.role)
      end
    end
  end
end
