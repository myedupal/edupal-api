FactoryBot.define do
  factory :price do
    transient do
      price_type { :stripe }
    end
    plan_id { create(:plan, price_type).id }
    amount { Faker::Number.within(range: 10..50) }
    billing_cycle { 'month' }

    trait :yearly do
      billing_cycle { 'year' }
    end
  end
end
