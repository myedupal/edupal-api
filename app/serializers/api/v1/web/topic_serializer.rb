class Api::V1::Web::TopicSerializer < ActiveModel::Serializer
  attributes :id, :name, :subject_id
  has_one :subject
end
