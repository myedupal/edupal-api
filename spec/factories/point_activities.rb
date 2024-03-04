FactoryBot.define do
  factory :point_activity do
    transient do
      user { create(:user) }
    end
    account_id { user.id }
    points { Faker::Number.within(range: 1..100) }
    # action_type {  }
    # activity_id { create(:activity).id }
  end
end
