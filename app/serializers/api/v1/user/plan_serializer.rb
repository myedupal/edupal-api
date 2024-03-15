class Api::V1::User::PlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :limits, :is_published

  has_many :prices
end
