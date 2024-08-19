class Api::V1::User::UserWithActiveSubscriptionSerializer < Api::V1::User::UserSerializer
  has_many :active_subscriptions
end
