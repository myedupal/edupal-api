FactoryBot.define do
  factory :referral_activity do
    transient do
      user { create(:user) }
    end

    user_id { user.id }
    referral_type { ReferralActivity.referral_types.keys.sample }
    voided { false }
    # referral_source { '' }
    credit_cents { Faker::Number.within(range: 5_00..15_00) }

    trait :user_signup do
      referral_type { ReferralActivity.referral_types[:signup] }
      referral_source { create(:user) }
    end

    trait :user_subscription do
      referral_type { ReferralActivity.referral_types[:subscription] }
      referral_source { create(:subscription) }
    end
  end
end
