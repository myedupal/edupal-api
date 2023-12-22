FactoryBot.define do
  factory :subscription do
    transient do
      user { create(:user) }
    end
    plan { create(:plan) }
    plan_id { plan.id }
    price_id { create(:price, plan: plan).id }
    user_id { user.id }
    created_by { user }
    start_at { Time.current }
    status { 'active' }

    trait :active do
      status { 'active' }
      start_at { Time.current }
      end_at { nil }
    end

    trait :incomplete do
      status { 'incomplete' }
    end
  end
end
