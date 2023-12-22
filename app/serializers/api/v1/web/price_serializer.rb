class Api::V1::Web::PriceSerializer < ActiveModel::Serializer
  attributes :id, :billing_cycle, :amount, :stripe_price_id
end
