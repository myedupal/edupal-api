FactoryBot.define do
  factory :subscription do
    transient do
      user { create(:user) }
      plan_type { :stripe }
      plan { create(:plan, plan_type) }
      price { create(:price, plan: plan) }
    end
    plan_id { plan.id }
    price_id { price.id }
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

    razorpay_subscription_id { 'sub_00000000000001' }
  end
end
