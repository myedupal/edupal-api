class Api::V1::Admin::TopicSerializer < ActiveModel::Serializer
  attributes :id, :name, :subject_id
  attributes :created_at, :updated_at
  has_one :subject
end
