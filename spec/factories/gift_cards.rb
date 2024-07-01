FactoryBot.define do
  factory :gift_card do
    transient do
      created_by { create(:admin) }
      plan { create(:plan) }
    end
    name { Faker::Lorem.unique.word }
    remark { Faker::Lorem.sentence }
    plan_id { plan&.id }
    created_by_id { created_by&.id }
    redemption_limit { Faker::Number.between(from: 10, to: 100) }
    # redemption_count { '' }
    expires_at { Faker::Time.between(from: Time.zone.now, to: 30.days.from_now) }
    # code { '' }
  end
end
