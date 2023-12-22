FactoryBot.define do
  factory :plan do
    name { Faker::Lorem.unique.word }
    # limits { '' }
    is_published { true }
  end
end
