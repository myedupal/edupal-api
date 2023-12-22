FactoryBot.define do
  factory :price do
    plan_id { create(:plan).id }
    amount { Faker::Number.within(range: 10..50) }
    billing_cycle { Price.billing_cycles.keys.sample }
  end
end
