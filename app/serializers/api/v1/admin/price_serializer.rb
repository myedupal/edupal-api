class Api::V1::Admin::PriceSerializer < ActiveModel::Serializer
  attributes :id, :billing_cycle, :amount, :stripe_price_id
  attributes :created_at, :updated_at
end
