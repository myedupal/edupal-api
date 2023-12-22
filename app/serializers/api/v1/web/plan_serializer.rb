class Api::V1::Web::PlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :limits, :is_published

  has_many :prices
end
