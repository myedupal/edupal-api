class Api::V1::Admin::PlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :limits, :is_published, :stripe_product_id,
             :plan_type, :referral_fee_percentage
  attributes :created_at, :updated_at

  has_many :prices
end
