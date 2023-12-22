class Api::V1::Admin::QuestionTopicSerializer < ActiveModel::Serializer
  attributes :id, :question_id, :topic_id
  attributes :created_at, :updated_at
  has_one :question
  has_one :topic
end
