class Api::V1::User::QuestionTopicSerializer < ActiveModel::Serializer
  attributes :id, :question_id, :topic_id
  has_one :question
  has_one :topic
end
