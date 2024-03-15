class Api::V1::User::SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :start_at, :end_at, :auto_renew, :stripe_subscription_id,
             :status, :cancel_at_period_end, :canceled_at, :cancel_reason,
             :current_period_start, :current_period_end,
             :plan_id, :price_id, :user_id, :created_by_id,
             :razorpay_subscription_id, :razorpay_short_url
  attributes :created_at, :updated_at
  has_one :plan
  has_one :price
  # has_one :user
  # has_one :created_by
end
