class Api::V1::User::UserWithActiveSubscriptionSerializer < Api::V1::User::UserSerializer
  has_one :active_subscription
end
