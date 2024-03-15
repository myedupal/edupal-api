class Api::V1::User::PriceSerializer < ActiveModel::Serializer
  attributes :id, :billing_cycle, :amount
end
