FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.unique.word }
    # limits { '' }
    is_published { true }

    trait :stripe do
      plan_type { :stripe }
    end

    trait :razorpay do
      plan_type { :razorpay }
    end
  end
end
