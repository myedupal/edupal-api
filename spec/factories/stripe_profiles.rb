FactoryBot.define do
  factory :stripe_profile do
    transient do
      user { create(:user) }
    end
    user_id { user.id }
    customer_id { SecureRandom.uuid }
    payment_method_id { 'pm_card_visa' }
  end
end
