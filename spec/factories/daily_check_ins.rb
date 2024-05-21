FactoryBot.define do
  factory :daily_check_in do
    transient do
      user { create(:user) }
    end
    sequence(:date) { |n| Date.current + n.days }
    user_id { user.id }
  end
end
