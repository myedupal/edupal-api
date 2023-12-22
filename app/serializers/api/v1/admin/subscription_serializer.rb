class Api::V1::Admin::SubscriptionSerializer < ActiveModel::Serializer
  attributes :id, :start_at, :end_at, :status, :stripe_subscription_id, :price_id,
             :plan_id, :created_by_id, :cancel_at_period_end, :canceled_at,
             :cancel_reason, :current_period_start, :current_period_end, :user_id
  attributes :created_at, :updated_at
  has_one :plan
  has_one :price
  has_one :user
  has_one :created_by
end
