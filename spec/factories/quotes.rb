FactoryBot.define do
  factory :quote do
    transient do
      user { create(:user) }
    end
    user_id { user.id }
    created_by_id { user.id }
    stripe_quote_id {}
    status { 'draft' }
    quote_expire_at { Faker::Time.between(from: Time.zone.now - 30.days, to: Time.zone.now) }
  end
end
