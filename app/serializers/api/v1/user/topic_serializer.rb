class Api::V1::User::TopicSerializer < ActiveModel::Serializer
  attributes :id, :name, :subject_id, :display_order
  has_one :subject
end
