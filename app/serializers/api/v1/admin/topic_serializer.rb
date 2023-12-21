class Api::V1::Admin::TopicSerializer < ActiveModel::Serializer
  attributes :id, :name
  attributes :created_at, :updated_at
  has_one :subject
end
