class Api::V1::Web::PriceSerializer < ActiveModel::Serializer
  attributes :id, :billing_cycle, :amount
end
